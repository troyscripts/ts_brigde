'use strict';
// Server-only: keep binary data out of Lua PerformHttpRequest's C-string body.
const https = require('https');
const crypto = require('crypto');

const renderDocument = require(GetResourcePath(GetCurrentResourceName()) + '/server/document_image.js');

function upload(url, payloadJson, dataUri, callback, documentJson) {
    if (typeof callback !== 'function') return;
    let finished = false;
    const finish = (status, body) => {
        if (finished) return;
        finished = true;
        // Re-enter the FiveM main runtime before invoking a Lua function reference.
        setImmediate(() => callback(status, body));
    };
    let req;
    try {
        if (typeof url !== 'string' || !/^https:\/\/discord\.com\/api\/(?:v\d+\/)?webhooks\/\d+\/[\w-]+$/.test(url)) {
            finish(-1, ''); return;
        }
        if (typeof payloadJson !== 'string' || Buffer.byteLength(payloadJson) > 256 * 1024 ||
            typeof dataUri !== 'string' || dataUri.length > 24 * 1024 * 1024) {
            finish(-1, ''); return;
        }
        let jpeg;
        if (dataUri) {
            const match = /^data:image\/jpe?g;base64,([A-Za-z0-9+/]+={0,2})$/.exec(dataUri);
            if (!match || match[1].length % 4 !== 0) { finish(-1, ''); return; }
            jpeg = Buffer.from(match[1], 'base64');
            if (jpeg.length < 3 || jpeg.length > 16 * 1024 * 1024 ||
                jpeg[0] !== 255 || jpeg[1] !== 216 || jpeg[2] !== 255 || jpeg.toString('base64') !== match[1]) {
                finish(-1, ''); return;
            }
        }
        let document;
        if (documentJson !== undefined) {
            if (typeof documentJson !== 'string' || documentJson.length > 16000) { finish(-1, ''); return; }
            document = JSON.parse(documentJson);
            if (!document || typeof document.plate !== 'string' || document.plate.length > 8 ||
                typeof document.documentNumber !== 'string') { finish(-1, ''); return; }
        }
        if (!jpeg && !document) { finish(-1, ''); return; }
        const payload = JSON.parse(payloadJson);
        if (!payload || !Array.isArray(payload.embeds) || !payload.embeds[0]) { finish(-1, ''); return; }
        payload.allowed_mentions = { parse: [] };
        const files=[];
        if (document) {
            files.push({name:'kentekenbewijs.png',mime:'image/png',bytes:renderDocument(document)});
            payload.embeds[0].image={url:'attachment://kentekenbewijs.png'};
        }
        if (jpeg) {
            files.push({name:'screenshot.jpg',mime:'image/jpeg',bytes:jpeg});
            if (document) payload.embeds.push({title:'Voertuigfoto bij uitgifte',description:'Clientopname; illustratief beeld.',image:{url:'attachment://screenshot.jpg'}});
            else payload.embeds[0].image={url:'attachment://screenshot.jpg'};
        }
        payload.attachments=files.map((f,id)=>({id,filename:f.name}));
        let boundary;
        do { boundary = 'tsBridge' + crypto.randomBytes(18).toString('hex'); }
        while (files.some(f=>f.bytes.includes(boundary)) || JSON.stringify(payload).includes(boundary));
        const parts=[Buffer.from('--'+boundary+'\r\nContent-Disposition: form-data; name="payload_json"\r\nContent-Type: application/json\r\n\r\n'+JSON.stringify(payload)+'\r\n')];
        files.forEach((f,id)=>parts.push(Buffer.from('--'+boundary+'\r\nContent-Disposition: form-data; name="files['+id+']"; filename="'+f.name+'"\r\nContent-Type: '+f.mime+'\r\n\r\n'),f.bytes,Buffer.from('\r\n')));
        parts.push(Buffer.from('--'+boundary+'--\r\n'));
        const body=Buffer.concat(parts);
        req = https.request(url + '?wait=true', {
            method: 'POST',
            headers: { 'Content-Type': 'multipart/form-data; boundary=' + boundary,
                'Content-Length': body.length, 'User-Agent': 'TroyScripts-ts_bridge/1.0.2' }
        }, res => {
            const chunks = [];
            let size = 0;
            res.on('data', chunk => {
                size += chunk.length;
                if (size > 256 * 1024) { finish(0, ''); res.destroy(); return; }
                chunks.push(chunk);
            });
            res.on('end', () => finish(res.statusCode || 0, Buffer.concat(chunks).toString('utf8')));
            res.on('error', () => finish(0, ''));
            res.on('aborted', () => finish(0, ''));
        });
        const deadline = setTimeout(() => { finish(0, ''); req.destroy(); }, 25000);
        req.on('close', () => clearTimeout(deadline));
        req.on('error', () => { clearTimeout(deadline); finish(0, ''); });
        req.end(body);
    } catch (_) {
        // No URLs or exceptions containing webhook tokens leave this uploader.
        if (req) req.destroy();
        finish(req ? 0 : -1, '');
    }

}
exports('UploadDiscordPhoto', (url, payloadJson, dataUri, callback) => upload(url, payloadJson, dataUri, callback));
exports('UploadDiscordRegistration', (url, payloadJson, dataUri, documentJson, callback) => upload(url, payloadJson, dataUri, callback, documentJson));
