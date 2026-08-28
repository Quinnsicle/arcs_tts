const SHEET_ID = "1yGuP7IcjnG_jbua4KH57D_68VaEhwOPhMT2yJkxG838";

function doPost(e) {
  try {
    // Log incoming request for debugging
    Logger.log('doPost incoming e: ' + JSON.stringify(e));

    if (!e) {
      Logger.log('doPost called without event object');
      return ContentService.createTextOutput('No event object').setMimeType(ContentService.MimeType.TEXT);
    }

    // Determine raw content: prefer postData.contents, fall back to e.parameter.payload
    var raw = null;
    if (e.postData && e.postData.contents) {
      raw = e.postData.contents;
      Logger.log('doPost: postData.contents length=' + raw.length + ' type=' + (e.postData.type || ''));
    } else if (e.parameter && e.parameter.payload) {
      raw = e.parameter.payload;
      Logger.log('doPost: payload found in e.parameter');
    } else {
      Logger.log('doPost: no postData.contents and no e.parameter.payload');
      raw = "";
    }

    // If body is form-encoded like 'payload=%7B...%7D', extract and decode
    if (raw && raw.indexOf('payload=') === 0) {
      try {
        raw = decodeURIComponent(raw.substring(8));
        Logger.log('doPost: decoded form payload length=' + raw.length);
      } catch (err) {
        Logger.log('doPost: decodeURIComponent failed: ' + err);
      }
    }

    Logger.log('doPost: raw payload (first 1000 chars): ' + (raw ? raw.substring(0, 1000) : ''));

    var payload = {};
    try {
      if (raw && raw.trim() !== '') payload = JSON.parse(raw);
    } catch (err) {
      Logger.log('doPost JSON.parse error: ' + err + ' raw=' + raw.substring(0,200));
      payload = {};
    }
    const ss = SpreadsheetApp.openById(SHEET_ID);
    const sheet = ss.getSheetByName("Sheet1") || ss.getSheets()[0];
    const ts = new Date();

    // If you receive a single word test:
    if (payload.word) {
      sheet.appendRow([ts, payload.word]);
      return ContentService.createTextOutput("OK").setMimeType(ContentService.MimeType.TEXT);
    }

    // If payload contains players (SubmitGame format)
    // If this is a remove request from a player, mark matching game rows in the main sheet
    if (payload.action && String(payload.action) === 'remove_request') {
      var gameId = payload.game_id || '';
      var requester = payload.requester || '';
      var requester_color = payload.requester_color || '';
      var note = payload.notes || '';
      var req_ts = payload.timestamp || ts;
      // Ensure timestamp is in milliseconds for JavaScript Date constructor.
      var req_ts_ms = req_ts;
      try {
        if (typeof req_ts === 'number') {
          if (req_ts < 1e12) req_ts_ms = req_ts * 1000; // seconds -> ms
        } else if (typeof req_ts === 'string' && /^\d+$/.test(req_ts)) {
          var n = parseInt(req_ts, 10);
          req_ts_ms = (n < 1e12) ? n * 1000 : n;
        }
      } catch (e) {
        req_ts_ms = req_ts;
      }

      // We'll mark matching rows (column 2 == game_id) in column 18 with a flag
      var targetCol = 18;
      var data = sheet.getDataRange().getValues();
      for (var i = 0; i < data.length; i++) {
        try {
          var rowGameId = data[i][1]; // zero-based: [0]=ts, [1]=game_id
            if (String(rowGameId) === String(gameId) && String(gameId) !== '') {
            sheet.getRange(i + 1, targetCol).setValue('REMOVE_REQUESTED by ' + requester + ' (' + requester_color + ') at ' + new Date(req_ts_ms));
          }
        } catch (err) {
          // ignore row errors
        }
      }

      // Also append a compact log entry to the main sheet for traceability
      // Order: notes, requester, requester_color
      sheet.appendRow([ts, gameId, 'REMOVE_REQUEST', note, requester, requester_color, JSON.stringify(payload)]);
      return ContentService.createTextOutput('OK').setMimeType(ContentService.MimeType.TEXT);
    }

    if (payload.players && Array.isArray(payload.players)) {
      const notes = payload.notes || "";
      const game_id = payload.game_id || "";
      const act = payload.act || "";
      // helper to join cards arrays/objects into readable strings
      function joinCards(node) {
        if (!node) return "";
        if (Array.isArray(node)) {
          return node.map(function(el) {
            if (typeof el === 'string') return el;
            if (el === null || el === undefined) return "";
            if (typeof el === 'object') {
              if (el.label) return String(el.label);
              if (el.name) return String(el.name);
              // keep small fallback
              try { return JSON.stringify(el); } catch (e) { return String(el); }
            }
            return String(el);
          }).filter(function(s){ return s && s !== ""; }).join(' | ');
        }
        // single string
        if (typeof node === 'string') return node;
        try { return JSON.stringify(node); } catch (e) { return String(node); }
      }

      payload.players.forEach(function(p) {
        const name = p.name || "";
        const color = p.color || "";
        const power = (p.power !== undefined) ? p.power : ((p.scores && p.scores[0]) ? p.scores[0] : "");
        const objective = (p.objective !== undefined) ? p.objective : ((p.scores && p.scores[1]) ? p.scores[1] : "");
        const hand  = (p.hand_size !== undefined) ? p.hand_size : ((p.scores && p.scores[2]) ? p.scores[2] : "");
        const tycoon = (p.tycoon !== undefined) ? p.tycoon : ((p.scores && p.scores[4]) ? p.scores[4] : "");
        const captives = (p.captives !== undefined) ? p.captives : ((p.scores && p.scores[6]) ? p.scores[6] : "");
        const trophies = (p.trophies !== undefined) ? p.trophies : ((p.scores && p.scores[8]) ? p.scores[8] : "");
        const keeper = (p.keeper !== undefined) ? p.keeper : ((p.scores && p.scores[10]) ? p.scores[10] : "");
        const empath = (p.empath !== undefined) ? p.empath : ((p.scores && p.scores[12]) ? p.scores[12] : "");

        // initiative (boolean) -> display mark
        var initiative = "";
        if (p.initiative === true || p.initiative === 1 || String(p.initiative) === "true") initiative = "✓";

        // Cards: support p.cards (array of strings or objects) or p.area_cards / p.hand_cards
        var cardsStr = "";
        try {
          if (p.area_cards || p.hand_cards) {
            var areaS = joinCards(p.area_cards);
            var handS = joinCards(p.hand_cards);
            var parts = [];
            if (areaS && areaS.length) parts.push('Area: ' + areaS);
            if (handS && handS.length) parts.push('Hand: ' + handS);
            cardsStr = parts.join(' | ');
          } else if (p.cards) {
            cardsStr = joinCards(p.cards);
          }
        } catch (err) {
          cardsStr = '';
        }

        // Append each field to its own column. Last column keeps full JSON for debug.
        sheet.appendRow([ts, game_id, act, notes, name, color, initiative, power, objective, hand, tycoon, captives, trophies, keeper, empath, cardsStr, JSON.stringify(p)]);
      });
      return ContentService.createTextOutput("OK").setMimeType(ContentService.MimeType.TEXT);
    }

    // Fallback: append full JSON
    sheet.appendRow([ts, JSON.stringify(payload)]);
    return ContentService.createTextOutput("OK").setMimeType(ContentService.MimeType.TEXT);
  } catch (err) {
    Logger.log("doPost error: " + err);
    return ContentService.createTextOutput("Error: " + err).setMimeType(ContentService.MimeType.TEXT);
  }
}

function doGet(e) {
  return ContentService.createTextOutput('Web app deployed. Use POST to send data.');
}

function testDoPost() {
  const fake = {
    postData: {
      contents: JSON.stringify({ word: 'test-from-editor' })
    }
  };
  const res = doPost(fake);
  Logger.log('testDoPost result: ' + (res && res.getContent ? res.getContent() : JSON.stringify(res)));
}