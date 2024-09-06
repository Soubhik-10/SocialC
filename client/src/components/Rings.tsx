import React, { useState, useEffect, useRef } from "react";
import RINGS from "vanta/dist/vanta.rings.min";

const VantaEffect: React.FC = () => {
  const [vantaEffect, setVantaEffect] = useState<any>(null);
  const myRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!vantaEffect && myRef.current) {
      const effect = RINGS({
        el: myRef.current,
        mouseControls: true,
        touchControls: true,
        gyroControls: false,
        minHeight: 190.0,
        minWidth: 200.0,
        scale: 0.9,
        scaleMobile: 1.0,
        backgroundColor: 0x0, // Black background
        color: 0x3c0f7c, // Darker purple to reduce brightness
      });

      setVantaEffect(effect);
    }
    return () => {
      if (vantaEffect) vantaEffect.destroy();
    };
  }, [vantaEffect]);

  return (
    <>
      <div
        ref={myRef}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100vw",
          height: "100vh",
          zIndex: -1, // Ensure it's behind other content
        }}
      />
      {/* Semi-transparent overlay */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100vw",
          height: "100vh",
          background: "rgba(0, 0, 0, 0.3)", // Adjust the opacity to control the dimness
          zIndex: 0, // Ensure it's on top of the Vanta effect
        }}
      />
    </>
  );
};
export default VantaEffect;