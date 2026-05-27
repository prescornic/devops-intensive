import { useState } from 'react'
import { api } from './api'

const colors = ['red', 'green', 'blue']

function App() {
  const [index, setIndex] = useState(0)

  const handleClick = async () => {
    const nextIndex = (index + 1) % colors.length
    const nextColor = colors[nextIndex]

    setIndex(nextIndex)

    await api.post('/colors', {
      currentColor: nextColor,
    })
  }

  return (
    <div
      style={{
        height: '100vh',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      <button
        onClick={handleClick}
        style={{
          width: '200px',
          height: '200px',
          borderRadius: '50%',
          border: 'none',
          backgroundColor: colors[index],
          cursor: 'pointer',
        }}
      />
    </div>
  )
}

export default App
