'use strict';
// Server-rendered registration snapshot. No browser, native addon or npm install needed.
const zlib = require('zlib');
const atlas = require('./document_font.json');
const decoded = new Map();
function glyph(size, ch) {
    const key = size + ':' + ch;
    if (!decoded.has(key)) {
        const g = atlas[size][ch] || atlas[size]['?'];
        decoded.set(key, {w:g[0],h:g[1],data:zlib.inflateSync(Buffer.from(g[2],'base64'))});
    }
    return decoded.get(key);
}
const crcTable = Array.from({length:256}, (_, n) => {
    for (let k=0;k<8;k++) n = (n&1) ? 0xedb88320^(n>>>1) : n>>>1;
    return n>>>0;
});
function chunk(type, bytes) {
    const body = Buffer.concat([Buffer.from(type), bytes]);
    let crc=0xffffffff;
    for (const b of body) crc=crcTable[(crc^b)&255]^(crc>>>8);
    const head=Buffer.alloc(4), tail=Buffer.alloc(4);
    head.writeUInt32BE(bytes.length);tail.writeUInt32BE((crc^0xffffffff)>>>0);
    return Buffer.concat([head,body,tail]);
}
module.exports = function render(data) {
    const W=1040,H=720,pixels=Buffer.alloc(W*H*3);
    function rect(x,y,w,h,c) {
        for(let py=Math.max(0,y);py<Math.min(H,y+h);py++) for(let px=Math.max(0,x);px<Math.min(W,x+w);px++) {
            const i=(py*W+px)*3;pixels[i]=c[0];pixels[i+1]=c[1];pixels[i+2]=c[2];
        }
    }
    function text(value,x,y,size=26,color=[21,51,45],max=920) {
        const input=String(value ?? 'Onbekend').replace(/[\r\n\t]/g,' ').slice(0,160);
        let dx=x;
        for(const ch of input) {
            const g=glyph(size,ch);
            if(dx+g.w>x+max)break;
            for(let gy=0;gy<g.h;gy++)for(let gx=0;gx<g.w;gx++) {
                if(dx+gx>=W||y+gy>=H)continue;
                const a=g.data[gy*g.w+gx]/255,i=((y+gy)*W+dx+gx)*3;
                for(let c=0;c<3;c++)pixels[i+c]=Math.round(pixels[i+c]*(1-a)+color[c]*a);
            }
            dx+=g.w;
        }
    }
    const dark=[25,63,53], muted=[101,117,101];
    rect(0,0,W,H,[244,245,232]);rect(0,0,W,140,dark);
    text('NL',44,44,36,[230,236,198]);
    text('NEDERLAND • VOERTUIGREGISTRATIE',140,26,18,[210,221,191]);
    text('Kentekenbewijs',140,59,36,[255,255,255]);
    rect(0,140,W,52,[217,233,209]);text(data.status || 'GELDIG',52,149,26,[34,80,52]);
    rect(52,224,630,94,[24,42,42]);rect(55,227,624,88,[241,198,56]);
    rect(55,227,70,88,[23,67,129]);text('NL',68,270,26,[255,255,255]);
    text(data.plate,155,238,48,[23,29,28],500);
    text('REGISTRATIEGEGEVENS',52,347,18,muted);
    text('GEREGISTREERDE EIGENAAR',52,392,18,muted);text(data.owner,52,419,26);
    text('DOCUMENTNUMMER',52,481,18,muted);text(data.documentNumber,52,507,26,undefined,450);
    text('DATUM VAN UITGIFTE',540,481,18,muted);text(data.issued,540,507,26,undefined,440);
    text(data.modelName ? 'VOERTUIGMODEL' : 'VOERTUIGMODELCODE',52,563,18,muted);text(data.modelName || data.model,52,590,26);
    rect(0,660,W,1,[205,213,190]);text('TROY SCRIPTS • ROLEPLAY DOCUMENT • UITGIFTEMOMENT',52,682,18,muted);
    const raw=Buffer.alloc((W*3+1)*H);
    for(let y=0;y<H;y++)pixels.copy(raw,y*(W*3+1)+1,y*W*3,(y+1)*W*3);
    const ihdr=Buffer.alloc(13);ihdr.writeUInt32BE(W,0);ihdr.writeUInt32BE(H,4);ihdr[8]=8;ihdr[9]=2;
    return Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',ihdr),chunk('IDAT',zlib.deflateSync(raw)),chunk('IEND',Buffer.alloc(0))]);
};
