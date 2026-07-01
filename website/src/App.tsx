import { useRef, useState, useEffect } from 'react';
import { motion, useScroll, useTransform, useInView, AnimatePresence } from 'framer-motion';
import './index.css';

const STORY_SECTIONS = [
  { id: 'home', title: "Today's Pursuit", desc: "Start every day with direction, not another decision.\n\nHermes doesn't ask you to create a new to-do list every morning. Instead, it gradually surfaces knowledge from your long-term collections into Today's Pursuit, giving you a focused starting point without overwhelming you.", img: "/images/home_firsthalf.jpeg" },
  { id: 'starter', title: "Starter Workspace", desc: "Learn Hermes by using Hermes.\n\nEvery new installation begins with a Starter Workspace containing example Domains, Blocks, and Items. Explore it, understand the philosophy, then delete it whenever you're ready to build your own knowledge system.", img: "/images/starter.jpeg" },
  { id: 'create_workspace', title: "Create Workspace", desc: "Separate different parts of your life.\n\nWorkspaces isolate contexts such as Engineering, Personal Development, Research, or Startup ideas. Your mathematics shouldn't compete with your grocery list.", img: "/images/create_workspace.jpeg" },
  { id: 'switch_workspace', title: "Switch Workspace", desc: "Change environments instantly.\n\nMove between completely independent knowledge systems while keeping each focused and distraction free.", img: "/images/switch_workspace.jpeg" },
  { id: 'domains', title: "Domains", desc: "Your lifelong areas of mastery.\n\nDomains represent broad territories like Engineering, Philosophy, Health, Finance, or Design. They organize knowledge at the highest level.", img: "/images/domains.jpeg" },
  { id: 'blocks', title: "Blocks", desc: "Build foundations, not folders.\n\nBlocks divide Domains into focused subjects.\n\nEngineering → Python → Databases.\n\nEach Block becomes a home for deeply related knowledge.", img: "/images/blocks.jpeg" },
  { id: 'items', title: "Items", desc: "Everything begins as an Item.\n\nQuestions. Notes. Ideas. Articles. Observations. Reflections.\n\nHermes stores every form of knowledge intentionally rather than forcing everything into plain notes.", img: "/images/items.jpeg" },
  { id: 'question', title: "Question", desc: "Learning begins with curiosity.\n\nQuestions encourage active recall instead of passive reading. Write your answer. Compare it. Reflect. Complete it.\n\nHermes preserves both your answer and your evolving understanding.", img: "/images/question.jpeg" },
  { id: 'question_workflow', title: "Question (Workflow)", desc: "Knowledge isn't finished when you reveal the answer.\n\nEach completed question becomes part of your personal learning history, preserving your answer, the official solution, your reflection, and the completion date.\n\nLearning becomes reviewable.", img: "/images/question_secondhalf.jpeg" },
  { id: 'article', title: "Article", desc: "Read without distractions.\n\nHermes removes unnecessary UI and presents articles in a calm reading environment designed for concentration rather than endless scrolling.", img: "/images/article.jpeg" },
  { id: 'article_renderer', title: "Article Renderer", desc: "The interface disappears. The knowledge remains.\n\nSoft typography. Comfortable spacing. Markdown. LaTeX. Offline rendering.\n\nReading should feel peaceful.", img: "/images/article_render.png" },
  { id: 'note', title: "Note", desc: "Capture understanding in your own words.\n\nNotes aren't copies of articles.\n\nThey're what remains after you've understood something.", img: "/images/note.jpeg" },
  { id: 'observation', title: "Observation", desc: "Small moments become permanent knowledge.\n\nAn Observation records patterns you notice in everyday life before they're forgotten. Sometimes a single observation grows into a Reflection or an Evolutio.", img: "/images/observation.jpeg" },
  { id: 'idea', title: "Idea", desc: "Ideas deserve room to evolve.\n\nRecord a thought. Expand it over time. Connect it with other ideas. Promote it into a Project when it becomes actionable.", img: "/images/idea.jpeg" },
  { id: 'veritas', title: "Veritas", desc: "Truth over perfection.\n\nLife interrupts. Hermes doesn't punish missed days. Instead, Veritas lets you honestly record why progress paused, preserving reality instead of guilt.", img: "/images/veritas_firsthalf.jpeg" },
  { id: 'manual_collections', title: "Manual Collections", desc: "Bring your own knowledge.\n\nImport questions, articles, notes, or ideas that you've intentionally collected. Hermes becomes your personal knowledge pipeline rather than another recommendation engine.", img: "/images/manual_collections.jpeg" },
  { id: 'search', title: "Search", desc: "Search ideas, not folders.\n\nRemembering what you learned is more important than remembering where you stored it. Hermes searches meaning first.", img: "/images/search.jpeg" },
  { id: 'export', title: "Export", desc: "Your knowledge belongs to you.\n\nExport Blocks or entire Workspaces using the open .hermes format, ensuring your thinking remains portable and future proof.", img: "/images/export.jpeg" },
  { id: 'control_center', title: "Control Center", desc: "Everything in one place.\n\nManage Workspaces, Imports, Exports, Guides, Developer tools, and Workspace settings without leaving Hermes.", img: "/images/control_center_firsthalf.jpeg" },
  { id: 'lock_workspace', title: "Lock Workspace", desc: "Protect your private thinking.\n\nSensitive workspaces can be locked with a PIN, keeping personal knowledge separate from casual access.", img: "/images/locked.jpeg" }
];

function StoryBlock({ item, index, setActiveIndex }: { item: any, index: number, setActiveIndex: (idx: number) => void }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { margin: "-50% 0px -50% 0px" });

  useEffect(() => {
    if (isInView) {
      setActiveIndex(index);
    }
  }, [isInView, index, setActiveIndex]);

  return (
    <div ref={ref} className="story-section">
      <h2 className="t-heading" style={{ marginBottom: '40px' }}>{item.title}</h2>
      <p className="t-body" style={{ whiteSpace: 'pre-line' }}>{item.desc}</p>
    </div>
  );
}

function App() {
  const heroRef = useRef(null);
  const { scrollYProgress: heroProgress } = useScroll({
    target: heroRef,
    offset: ["start start", "end end"]
  });

  // Scale from 35% to 95% as we scroll the first 200vh
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
              <img src="/images/home_firsthalf.jpeg" alt="Hermes" />
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
                src={STORY_SECTIONS[activeIndex].img}
                alt={STORY_SECTIONS[activeIndex].title}
                initial={{ opacity: 0, scale: 0.94, y: 40 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }} // Apple-like custom spring/ease
                style={{ position: 'absolute', top: 0, left: 0 }}
              />
            </AnimatePresence>
          </div>
        </div>

      </div>

      {/* Final Philosophy Footer */}
      <div style={{ height: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '0 40px' }}>
        <h2 className="t-heading" style={{ marginBottom: '40px' }}>Information is easy to collect.</h2>
        <h2 className="t-heading" style={{ marginBottom: '80px', color: 'var(--text-secondary)' }}>Understanding is difficult to preserve.</h2>
        <p className="t-section" style={{ maxWidth: '800px', marginBottom: '120px' }}>
          Hermes exists to bridge the distance between the two.
        </p>
        
        <button style={{ 
          background: '#fff', color: '#000', border: 'none', 
          padding: '20px 40px', borderRadius: '40px', 
          fontSize: '21px', fontWeight: 600, cursor: 'pointer',
          transition: 'transform 0.2s'
        }} onMouseEnter={(e) => e.currentTarget.style.transform = 'scale(1.05)'}
           onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}>
          View on GitHub
        </button>
      </div>

    </div>
  );
}

export default App;
