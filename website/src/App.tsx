import { useRef, useState, useEffect } from 'react';
import { motion, useScroll, useTransform, useInView, AnimatePresence } from 'framer-motion';
import { Check, ChevronDown, ChevronUp } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import { STORY_SECTIONS } from './data';
import './index.css';

function parseContent(markdown: string) {
  const lines = markdown.split('\n');
  let subtitle = '';
  let highlights: string[] = [];
  
  let inPurpose = false;
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('## Purpose') || trimmed.startsWith('## Why Hermes Exists')) {
      inPurpose = true;
      continue;
    }
    if (trimmed.startsWith('## ')) {
      inPurpose = false;
      highlights.push(trimmed.replace('## ', ''));
      continue;
    }
    if (inPurpose && trimmed && !trimmed.startsWith('>')) {
      if (!subtitle) {
        subtitle = trimmed;
      } else if (subtitle.length < 120) {
        subtitle += ' ' + trimmed;
      }
    }
  }
  
  if (!subtitle) {
    const firstText = lines.find(l => l.trim() && !l.startsWith('#') && !l.startsWith('>'));
    if (firstText) subtitle = firstText.trim();
  }
  
  return { subtitle, highlights: highlights.slice(0, 5) };
}

function StoryBlock({ item, index, setActiveIndex }: { item: any, index: number, setActiveIndex: (idx: number) => void }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { margin: "-50% 0px -50% 0px" });
  const [expanded, setExpanded] = useState(false);

  useEffect(() => {
    if (isInView) {
      setActiveIndex(index);
    }
  }, [isInView, index, setActiveIndex]);

  const { subtitle, highlights } = parseContent(item.desc);

  return (
    <div ref={ref} className="story-section" style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '40px 0' }}>
      <h2 className="t-heading" style={{ marginBottom: '24px' }}>{item.title}</h2>
      <p className="t-body" style={{ marginBottom: '40px' }}>{subtitle}</p>

      {highlights.length > 0 && (
        <ul style={{ listStyle: 'none', marginBottom: '40px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {highlights.map((h, i) => (
            <li key={i} style={{ display: 'flex', alignItems: 'center', gap: '16px', color: 'var(--text-secondary)', fontSize: '18px', fontWeight: 500 }}>
              <Check size={20} color="#fff" />
              {h}
            </li>
          ))}
        </ul>
      )}

      <div>
        <button 
          onClick={() => setExpanded(!expanded)}
          style={{
            background: 'rgba(255,255,255,0.05)',
            border: '1px solid rgba(255,255,255,0.1)',
            color: '#fff',
            padding: '12px 24px',
            borderRadius: '100px',
            fontSize: '16px',
            fontWeight: 500,
            cursor: 'pointer',
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'background 0.2s'
          }}
          onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,255,255,0.1)'}
          onMouseLeave={e => e.currentTarget.style.background = 'rgba(255,255,255,0.05)'}
        >
          {expanded ? 'Collapse' : 'Learn More'}
          {expanded ? <ChevronUp size={18} /> : <ChevronDown size={18} />}
        </button>
      </div>

      <AnimatePresence>
        {expanded && (
          <motion.div 
            initial={{ height: 0, opacity: 0 }} 
            animate={{ height: 'auto', opacity: 1 }} 
            exit={{ height: 0, opacity: 0 }}
            style={{ overflow: 'hidden' }}
          >
            <div className="markdown-content" style={{ marginTop: '40px', color: 'var(--text-secondary)', fontSize: '18px', lineHeight: 1.6 }}>
              <ReactMarkdown>{item.desc}</ReactMarkdown>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function App() {
  const heroRef = useRef(null);
  const { scrollYProgress: heroProgress } = useScroll({
    target: heroRef,
    offset: ["start start", "end end"]
  });

  // Scale from 35% to 95% as we scroll the first 250vh
  const scale = useTransform(heroProgress, [0, 0.8], [0.35, 0.95]);
  // Fade out the hero text
  const opacity = useTransform(heroProgress, [0, 0.2], [1, 0]);

  const [activeIndex, setActiveIndex] = useState(0);

  return (
    <div>
      {/* Hero Intro - Cinematic Scale */}
      <div ref={heroRef} style={{ height: '250vh' }}>
        <div style={{ position: 'sticky', top: 0, height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}>
          
          {/* Hero Text */}
          <motion.div style={{ position: 'absolute', opacity, textAlign: 'center', zIndex: 10 }}>
            <h1 className="t-hero gradient-text" style={{ marginBottom: '40px' }}>Hermes OS</h1>
            <p className="t-section" style={{ color: 'var(--text-secondary)' }}>The Personal Development Operating System.</p>
          </motion.div>

          {/* Growing Phone */}
          <motion.div style={{ scale, transformOrigin: 'center center' }}>
            <div className="phone-frame">
              <img src="/images/home_firsthalf.jpeg" alt="Hermes Dashboard" />
            </div>
          </motion.div>
        </div>
      </div>

      {/* Story Sequence */}
      <div className="story-container">
        
        {/* Left: Scrolling Text */}
        <div className="story-left">
          {STORY_SECTIONS.map((item, index) => (
            <StoryBlock 
              key={item.id} 
              item={item} 
              index={index} 
              setActiveIndex={setActiveIndex} 
            />
          ))}
        </div>

        {/* Right: Sticky Phone */}
        <div className="story-right">
          <div className="phone-frame">
            <AnimatePresence mode="wait">
              <motion.img
                key={activeIndex}
                // Fallback image if one is missing (e.g. export.md -> export.jpeg)
                src={STORY_SECTIONS[activeIndex]?.img || '/images/home_firsthalf.jpeg'}
                alt={STORY_SECTIONS[activeIndex]?.title || 'Hermes UI'}
                initial={{ opacity: 0, scale: 0.94, y: 40 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
              />
            </AnimatePresence>
          </div>
        </div>

      </div>

      {/* Final Philosophy Footer */}
      <div style={{ padding: '200px 40px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', borderTop: '1px solid #1a1a1a' }}>
        <h2 className="t-heading" style={{ marginBottom: '40px' }}>Information is easy to collect.</h2>
        <h2 className="t-heading" style={{ marginBottom: '80px', color: 'var(--text-secondary)' }}>Understanding is difficult to preserve.</h2>
        <p className="t-section" style={{ maxWidth: '800px', marginBottom: '160px' }}>
          Hermes exists to bridge the distance between the two.
        </p>
        
        <div style={{ display: 'flex', gap: '60px', color: 'var(--text-secondary)', fontSize: '18px', fontWeight: 500 }}>
          <a href="#" style={{ color: 'inherit', textDecoration: 'none', transition: 'color 0.2s' }} onMouseEnter={e => e.currentTarget.style.color = '#fff'} onMouseLeave={e => e.currentTarget.style.color = 'var(--text-secondary)'}>GitHub</a>
          <a href="#" style={{ color: 'inherit', textDecoration: 'none', transition: 'color 0.2s' }} onMouseEnter={e => e.currentTarget.style.color = '#fff'} onMouseLeave={e => e.currentTarget.style.color = 'var(--text-secondary)'}>Latest Release</a>
          <a href="#" style={{ color: 'inherit', textDecoration: 'none', transition: 'color 0.2s' }} onMouseEnter={e => e.currentTarget.style.color = '#fff'} onMouseLeave={e => e.currentTarget.style.color = 'var(--text-secondary)'}>Documentation</a>
          <a href="#" style={{ color: 'inherit', textDecoration: 'none', transition: 'color 0.2s' }} onMouseEnter={e => e.currentTarget.style.color = '#fff'} onMouseLeave={e => e.currentTarget.style.color = 'var(--text-secondary)'}>License</a>
          <span style={{ color: '#444' }}>v3.0.0</span>
        </div>
      </div>

    </div>
  );
}

export default App;
