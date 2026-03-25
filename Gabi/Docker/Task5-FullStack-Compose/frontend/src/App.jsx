import React, { useEffect, useState } from 'react'

export default function App() {
  const [health, setHealth] = useState(null)
  const [users, setUsers] = useState([])
  const [cache, setCache] = useState(null)

  const fetchHealth = async () => {
    const res = await fetch('/api/health')
    const data = await res.json()
    setHealth(data)
  }

  const fetchUsers = async () => {
    const res = await fetch('/api/users')
    const data = await res.json()
    setUsers(data)
  }

  const fetchCache = async () => {
    const res = await fetch('/api/cache')
    const data = await res.json()
    setCache(data)
  }

  useEffect(() => {
    fetchHealth()
    fetchUsers()
  }, [])

  return (
    <div style={{ fontFamily: 'Arial, sans-serif', padding: '2rem' }}>
      <h1>Full Stack App with Docker Compose</h1>
      <p>Frontend: React | Backend: Flask | DB: PostgreSQL | Cache: Redis | Proxy: Nginx</p>

      <section style={{ marginTop: '2rem' }}>
        <h2>Backend Health</h2>
        <button onClick={fetchHealth}>Refresh Health</button>
        <pre>{health ? JSON.stringify(health, null, 2) : 'Loading...'}</pre>
      </section>

      <section style={{ marginTop: '2rem' }}>
        <h2>Users</h2>
        <button onClick={fetchUsers}>Refresh Users</button>
        <pre>{JSON.stringify(users, null, 2)}</pre>
      </section>

      <section style={{ marginTop: '2rem' }}>
        <h2>Redis Cache Demo</h2>
        <button onClick={fetchCache}>Increment Counter</button>
        <pre>{cache ? JSON.stringify(cache, null, 2) : 'Click button to test Redis'}</pre>
      </section>
    </div>
  )
}