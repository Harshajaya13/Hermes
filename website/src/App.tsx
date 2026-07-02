import { useRef, useState } from 'react';
import { motion, useScroll, useTransform, AnimatePresence, useSpring } from 'framer-motion';
import { Check, ChevronDown, ChevronUp } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import { STORY_SECTIONS } from './data';
import './index.css';

function parseContent(markdown: string) {
  const lines = markdown.split('\n');
  let subtitle = '';
  let highlights: string[] = [];
  let shortDescLines: string[] = [];
  let paragraphCount = 0;
  
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
    
    // Extract a tiny "Learn More" summary (max 2 paragraphs) to keep the website punchy
    if (trimmed.length > 30 && !trimmed.startsWith('#') && !trimmed.startsWith('>')) {
      if (paragraphCount < 2 && !shortDescLines.includes(trimmed)) {
        shortDescLines.push(trimmed);
        paragraphCount++;
      }
    }
  }
  
  if (!subtitle) {
    const firstText = lines.find(l => l.trim() && !l.startsWith('#') && !l.startsWith('>'));
    if (firstText) subtitle = firstText.trim();
  }
  
  return { 
    subtitle, 
    highlights: highlights.slice(0, 4), // Apple-style: max 4 feature chips 
    shortDesc: shortDescLines.join('\n\n')
  };
}

function StoryBlock({ item }: { item: any }) {
  const [expanded, setExpanded] = useState(false);
  const { subtitle, highlights, shortDesc } = parseContent(item.desc);

  return (
    <div className="story-section" style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '120px 20px', textAlign: 'center' }}>
      
      {/* Hook */}
      <h2 className="t-heading" style={{ marginBottom: '16px' }}>{item.title}</h2>
      
      {/* One Sentence */}
      <p className="t-body" style={{ marginBottom: '80px', maxWidth: '600px', color: 'var(--text-secondary)' }}>{subtitle}</p>

      {/* Large Phone Hero */}
      <motion.div 
        initial={{ opacity: 0, y: 40 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-20%" }}
        transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        style={{ marginBottom: '80px' }}
      >
        <div className="phone-frame">
          <img src={item.img || '/images/home_firsthalf.jpeg'} alt={item.title} />
        </div>
      </motion.div>

      {/* Feature Chips */}
      {highlights.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', gap: '16px', marginBottom: '60px', maxWidth: '800px' }}>
          {highlights.map((h, i) => (
            <div key={i} style={{ 
              background: 'rgba(255,255,255,0.03)', 
              padding: '12px 24px', 
              borderRadius: '100px', 
              border: '1px solid rgba(255,255,255,0.1)', 
              display: 'flex', 
              alignItems: 'center', 
              gap: '12px',
              boxShadow: '0 4px 20px rgba(0,0,0,0.2)'
            }}>
              <Check size={18} color="#fff" />
              <span style={{ fontSize: '16px', fontWeight: 500, color: 'var(--text-secondary)' }}>{h}</span>
            </div>
          ))}
        </div>
      )}

      {/* Learn More Button */}
      <div style={{ marginBottom: expanded ? '40px' : '0' }}>
        <button 
          onClick={() => setExpanded(!expanded)}
          style={{
            background: expanded ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.05)',
            border: '1px solid rgba(255,255,255,0.1)',
            color: '#fff',
            padding: '14px 32px',
            borderRadius: '100px',
            fontSize: '16px',
            fontWeight: 500,
            cursor: 'pointer',
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.2s'
          }}
          onMouseEnter={e => e.currentTarget.style.background = 'rgba(255,255,255,0.1)'}
          onMouseLeave={e => e.currentTarget.style.background = expanded ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.05)'}
        >
          {expanded ? 'Collapse' : 'Learn More'}
          {expanded ? <ChevronUp size={18} /> : <ChevronDown size={18} />}
        </button>
      </div>

      {/* Expandable Markdown */}
      <AnimatePresence>
        {expanded && (
          <motion.div 
            initial={{ height: 0, opacity: 0 }} 
            animate={{ height: 'auto', opacity: 1 }} 
            exit={{ height: 0, opacity: 0 }}
            style={{ overflow: 'hidden', width: '100%', maxWidth: '800px', textAlign: 'left' }}
          >
            <div className="markdown-content" style={{ padding: '32px', background: 'rgba(255,255,255,0.02)', borderRadius: '24px', border: '1px solid rgba(255,255,255,0.05)' }}>
              <ReactMarkdown>{shortDesc}</ReactMarkdown>
              <div style={{ marginTop: '24px', paddingTop: '24px', borderTop: '1px solid rgba(255,255,255,0.05)', textAlign: 'center' }}>
                <a 
                  href={`https://github.com/Harshajaya13/Hermes#${item.title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  style={{ fontSize: '14px', color: 'var(--text-tertiary)', textDecoration: 'none', transition: 'color 0.2s' }}
                  onMouseEnter={e => e.currentTarget.style.color = '#fff'}
                  onMouseLeave={e => e.currentTarget.style.color = 'var(--text-tertiary)'}
                >
                  Read the full methodology on GitHub →
                </a>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function App() {
  const heroRef = useRef(null);
  const { scrollYProgress: rawHeroProgress } = useScroll({
    target: heroRef,
    offset: ["start start", "end end"]
  });

  // Apply Apple-like physics to the scroll animation so it feels smooth like butter
  const heroProgress = useSpring(rawHeroProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001
  });

  const isMobile = typeof window !== 'undefined' && window.innerWidth < 900;
  // Scale from 35% to 95% on desktop
  const scale = useTransform(heroProgress, [0, 0.8], [0.35, 0.95]);
  // Fade out the hero text
  const opacity = useTransform(heroProgress, [0, 0.2], [1, 0]);
  
  // Crossfade between locked and unlocking on desktop
  const lockedOpacity = useTransform(heroProgress, [0.3, 0.5], [1, 0]);
  const unlockingOpacity = useTransform(heroProgress, [0.3, 0.5], [0, 1]);

  return (
    <div>
      {/* Hero Intro - Cinematic Scale */}
      {isMobile ? (
        <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', overflow: 'hidden', padding: '60px 20px', gap: '40px' }}>
          <div style={{ textAlign: 'center', zIndex: 10 }}>
            <h1 className="t-hero gradient-text" style={{ marginBottom: '20px' }}>Hermes OS</h1>
            <p className="t-section" style={{ color: 'var(--text-secondary)' }}>The Personal Development Operating System.</p>
          </div>
          
          <div className="phone-frame" style={{ transform: 'translateZ(0)' }}>
            <img src="/images/unlocking.jpeg" alt="Hermes Dashboard" loading="eager" />
          </div>
        </div>
      ) : (
        <div ref={heroRef} style={{ height: '250vh' }}>
          <div style={{ position: 'sticky', top: 0, height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden' }}>
            
            {/* Hero Text */}
            <motion.div style={{ position: 'absolute', opacity, textAlign: 'center', zIndex: 10 }}>
              <h1 className="t-hero gradient-text" style={{ marginBottom: '40px' }}>Hermes OS</h1>
              <p className="t-section" style={{ color: 'var(--text-secondary)' }}>The Personal Development Operating System.</p>
            </motion.div>

            {/* Growing Phone */}
            <motion.div style={{ scale, transformOrigin: 'center center', willChange: 'transform' }}>
              <div className="phone-frame" style={{ transform: 'translateZ(0)', position: 'relative' }}>
                <motion.img 
                  style={{ opacity: lockedOpacity, position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }} 
                  src="/images/locked.jpeg" 
                  alt="Hermes Locked" 
                  loading="eager" 
                />
                <motion.img 
                  style={{ opacity: unlockingOpacity, width: '100%', height: '100%' }} 
                  src="/images/unlocking.jpeg" 
                  alt="Hermes Unlocking" 
                  loading="eager" 
                />
              </div>
            </motion.div>
          </div>
        </div>
      )}

      {/* Story Sequence (Vertical Apple-style Layout) */}
      <div style={{ maxWidth: '1200px', margin: '0 auto', display: 'flex', flexDirection: 'column', gap: '100px' }}>
        {STORY_SECTIONS.map((item) => (
          <StoryBlock 
            key={item.id} 
            item={item} 
          />
        ))}
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
