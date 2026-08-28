#!/usr/bin/env python3
"""
Convert a leaders YAML file into a Lua snippet that appends entries to
`starting_pieces` in `Global.lua`.

Usage:
  python tools/yml_to_lua.py assets/leaders.yml -o assets/leaders_starting_pieces.lua
  then copy this over in global.lua

Options:
  --key-field FIELD   Use FIELD from each YAML entry as the Lua table key (default: 'id').
  --use-name-key      Use normalized name as the key instead of an explicit field.
  --pretty            Pretty-print Lua with indentation (default: on).

The script expects the YAML to be a mapping (dict) of entries or a list of
objects. Each leader entry should contain fields like `setup` (A/B/C/D) and
`resources` to map into the `starting_pieces` structure.

Output is a Lua file you can paste into `Global.lua` (after the existing
`starting_pieces` table). The script will emit assignments that add/replace
entries in `starting_pieces`.
"""

import argparse
import copy
import os
import re
import sys

import yaml


def norm_key_from_name(name: str) -> str:
    s = name or ""
    # normalize to lowercase, remove non-alphanum, replace spaces with _
    s = s.strip()
    s = re.sub(r"[^0-9A-Za-z]+", "_", s)
    s = s.strip("_")
    return s.lower()


def lua_escape(s: str) -> str:
    if s is None:
        return "nil"
    s = str(s)
    s = s.replace('\\', '\\\\').replace('"', '\\"')
    return '"%s"' % s


def is_lua_identifier(k: str) -> bool:
    return re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", k) is not None


def serialize_lua(value, indent=0, pretty=True):
    pad = '  ' * indent if pretty else ''
    if value is None:
        return 'nil'
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return str(value)
    if isinstance(value, str):
        return lua_escape(value)
    if isinstance(value, (list, tuple)):
        if not value:
            return '{}'
        items = []
        for v in value:
            items.append(serialize_lua(v, indent + 1, pretty))
        if pretty:
            inner = ', '.join(items)
            return '{' + inner + '}' if len(inner) < 60 else '{\n' + ',\n'.join('  ' * (indent + 1) + it for it in items) + '\n' + pad + '}'
        else:
            return '{' + ','.join(items) + '}'
    if isinstance(value, dict):
        if not value:
            return '{}'
        lines = []
        for k, v in value.items():
            if is_lua_identifier(k):
                key = k
            else:
                key = '["%s"]' % str(k).replace('"', '\\"')
            val = serialize_lua(v, indent + 1, pretty)
            if pretty:
                lines.append(pad + '  ' + f'{key} = {val}')
            else:
                lines.append(f'{key}={val}')
        if pretty:
            return '{\n' + ',\n'.join(lines) + '\n' + pad + '}'
        else:
            return '{' + ','.join(lines) + '}'
    # fallback
    return lua_escape(str(value))


def convert_entry_to_starting_pieces(entry):
    # entry expected to contain a `setup` mapping and an optional `resources` list
    lp = {}
    setup = entry.get('setup') or entry.get('starting') or entry.get('start') or {}
    # Ensure A,B,C,D keys preserved
    for letter in ['A', 'B', 'C', 'D']:
        val = setup.get(letter) if isinstance(setup, dict) else None
        if val:
            sub = {}
            if 'building' in val:
                sub['building'] = val['building']
            if 'ships' in val:
                sub['ships'] = val['ships']
            # if there are other numeric/boolean values that should be preserved, add here
            lp[letter] = sub
    # resources may be a list, a single string, or absent.
    resources = entry.get('resources')
    if resources is None:
        resources = entry.get('resource')

    if isinstance(resources, list):
        if resources:
            lp['resources'] = resources
    elif isinstance(resources, str):
        # allow a single resource string to be treated as a one-item list
        s = resources.strip()
        if s != "":
            lp['resources'] = [s]
    # if resources is missing or empty, do not add the key (preserve nil)
    # Ensure D is present: if D not defined but C is, copy C into D
    if 'D' not in lp and 'C' in lp:
        lp['D'] = copy.deepcopy(lp['C'])
    return lp


def main(argv=None):
    p = argparse.ArgumentParser()
    p.add_argument('yaml', help='Input YAML file (e.g. assets/leaders.yml)')
    p.add_argument('-o', '--output', help='Output Lua file (default stdout)')
    p.add_argument('--key-field', default='id', help='YAML field to use as key for starting_pieces')
    p.add_argument('--use-name-key', action='store_true', help='Use normalized name as key')
    p.add_argument('--pretty', action='store_true', dest='pretty', default=True, help='Pretty print Lua')
    args = p.parse_args(argv)

    if not os.path.exists(args.yaml):
        print('Input YAML not found:', args.yaml, file=sys.stderr)
        sys.exit(2)

    with open(args.yaml, 'r', encoding='utf-8') as fh:
        data = yaml.safe_load(fh)

    entries = []
    if isinstance(data, dict):
        # assume mapping name -> details
        for name, details in data.items():
            if not isinstance(details, dict):
                continue
            details = dict(details)
            details['_name'] = name
            entries.append(details)
    elif isinstance(data, list):
        for item in data:
            if isinstance(item, dict):
                entries.append(item)
    else:
        print('Unexpected YAML root type: %s' % type(data), file=sys.stderr)
        sys.exit(3)

    out_lines = []
    out_lines.append('-- Generated by tools/yml_to_lua.py from %s' % os.path.basename(args.yaml))
    out_lines.append('starting_pieces = starting_pieces or {}')
    out_lines.append('')

    for e in entries:
        # determine key
        key = None
        if args.use_name_key:
            name = e.get('_name') or e.get('name') or e.get('display') or e.get('title')
            if not name:
                name = e.get(args.key_field)
            key = norm_key_from_name(name or '')
        else:
            key = e.get(args.key_field) or e.get('code') or e.get('hex') or e.get('guid') or e.get('_name') or e.get('name')
            if key is None:
                # fallback to normalized name
                name = e.get('_name') or e.get('name')
                key = norm_key_from_name(name or 'unknown')
        key = str(key)

        lp = convert_entry_to_starting_pieces(e)
        # skip empty lp? still emit placeholder
        comment = e.get('_name') or e.get('name')
        if comment:
            out_lines.append('-- %s' % comment)
        # we will emit: starting_pieces["key"] = { ... }
        lua_val = serialize_lua(lp, indent=0, pretty=args.pretty)
        out_lines.append('starting_pieces["%s"] = %s' % (key, lua_val))
        out_lines.append('')

    output = '\n'.join(out_lines)

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as fh:
            fh.write(output)
        print('Wrote', args.output)
    else:
        print(output)


if __name__ == '__main__':
    main()
