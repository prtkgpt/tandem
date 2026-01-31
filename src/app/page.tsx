export default function Home() {
  return (
    <div style={{ fontFamily: "system-ui", padding: "2rem", maxWidth: 480 }}>
      <h1>Tandem API</h1>
      <p>Backend for the Tandem iOS app.</p>
      <p style={{ color: "#888", fontSize: 14 }}>
        All endpoints live under <code>/api/*</code>
      </p>
    </div>
  );
}
