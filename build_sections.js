const fs = require('fs');
const path = require('path');

const order = [
  { id: 'home', file: 'home.md', img: '/images/home_firsthalf.jpeg' },
  { id: 'domains', file: 'domain.md', img: '/images/domains.jpeg' },
  { id: 'blocks', file: 'blocks.md', img: '/images/blocks.jpeg' },
  { id: 'items', file: 'items.md', img: '/images/items.jpeg' },
  { id: 'question', file: 'questions.md', img: '/images/question.jpeg' },
  { id: 'article', file: 'articles.md', img: '/images/article.jpeg' },
  { id: 'note', file: 'notes.md', img: '/images/note.jpeg' },
  { id: 'observation', file: 'observations.md', img: '/images/observation.jpeg' },
  { id: 'idea', file: 'ideas.md', img: '/images/idea.jpeg' },
  { id: 'evolutio', file: 'evolutio.md', img: '/images/idea.jpeg' }, // fallback image
  { id: 'veritas', file: 'veritas', img: '/images/veritas_firsthalf.jpeg' },
  { id: 'search', file: 'search.md', img: '/images/search.jpeg' },
  { id: 'manual_collections', file: 'manual_collections.md', img: '/images/manual_collections.jpeg' },
  { id: 'import', file: 'import_collections.md', img: '/images/import_collections.jpeg' },
  { id: 'export', file: 'export.md', img: '/images/export.jpeg' }, // wait export.md might not exist, let's check
  { id: 'control_center', file: 'control_center.md', img: '/images/control_center_firsthalf.jpeg' },
  { id: 'about', file: 'about.md', img: '/images/about.jpeg' }
];

const dir = 'description';
const out = [];

for (const o of order) {
  const fp = path.join(dir, o.file);
  let content = '';
  if (fs.existsSync(fp)) {
    content = fs.readFileSync(fp, 'utf8');
  } else if (fs.existsSync(fp.replace('.md', ''))) {
    content = fs.readFileSync(fp.replace('.md', ''), 'utf8');
  } else {
    // maybe it doesn't exist
    content = "missing file: " + fp;
  }
  
  // parse title and desc
  let title = o.id;
  let lines = content.split('\n');
  if (lines[0].startsWith('# ')) {
    title = lines[0].replace('# ', '').trim();
    lines = lines.slice(1);
  }
  
  let desc = lines.join('\n').trim();
  
  out.push({
    id: o.id,
    title,
    desc,
    img: o.img
  });
}

console.log(JSON.stringify(out, null, 2));
