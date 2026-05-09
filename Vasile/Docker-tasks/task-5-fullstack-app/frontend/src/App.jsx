import { useEffect, useState } from 'react'

function App() {
  const [health, setHealth] = useState(null)

  useEffect(() => {
    fetch('/api/health')
      .then(res => res.json())
      .then(data => setHealth(data.status))
      .catch(() => setHealth('Backend unavailable'))
  }, [])

  return (
    <div style={{ padding: '40px', fontFamily: 'Arial' }}>
      <h1>Full-Stack Docker Compose App</h1>

      <p>
        Frontend is running successfully.
      </p>

      <p>
        Backend Health: <strong>{health}</strong>
      </p>
    </div>
  )
}

export default App