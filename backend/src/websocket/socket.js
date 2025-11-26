const { initializeSocketIO } = require('./socketHandler');

/**
 * Wrap Socket.IO initialization and add verbose logging for all events.
 *
 * - Logs connect / disconnect with userId + socketId
 * - Logs every incoming event from frontend via socket.onAny
 * - Logs every outgoing event from backend via patched socket.emit
 */
const setupSocket = (io) => {
  // First, initialize existing business logic handlers
  initializeSocketIO(io);

  // Then, attach logging layer
  io.on('connection', (socket) => {
    const uid = () => socket.userId || 'unknown';

    console.log(`🔌 [socket] connected: user=${uid()} socket=${socket.id}`);

    // Log all incoming events from this socket
    socket.onAny((event, ...args) => {
      try {
        const first = args[0];
        let preview;
        if (first === undefined) {
          preview = '';
        } else if (typeof first === 'object') {
          preview = JSON.stringify(first).slice(0, 400);
        } else {
          preview = String(first).slice(0, 400);
        }
        console.log(
          `📥 [socket] recv  user=${uid()} socket=${socket.id}  event=${event}  payload=${preview}`
        );
      } catch (err) {
        console.log(
          `📥 [socket] recv  user=${uid()} socket=${socket.id}  event=${event}  (payload not loggable: ${err.message})`
        );
      }
    });

    // Patch emit to log all outgoing events to this socket
    const originalEmit = socket.emit.bind(socket);
    socket.emit = (event, ...args) => {
      try {
        const first = args[0];
        let preview;
        if (first === undefined) {
          preview = '';
        } else if (typeof first === 'object') {
          preview = JSON.stringify(first).slice(0, 400);
        } else {
          preview = String(first).slice(0, 400);
        }
        console.log(
          `📤 [socket] emit  user=${uid()} socket=${socket.id}  event=${event}  payload=${preview}`
        );
      } catch (err) {
        console.log(
          `📤 [socket] emit  user=${uid()} socket=${socket.id}  event=${event}  (payload not loggable: ${err.message})`
        );
      }
      return originalEmit(event, ...args);
    };

    socket.on('disconnect', (reason) => {
      console.log(`❌ [socket] disconnected: user=${uid()} socket=${socket.id} reason=${reason}`);
    });
  });
};

module.exports = { setupSocket };


