import { WebSocketServer } from 'ws';

export default class Socket {

    private static connections: Array<WebSocket> = [];

    private static wss: WebSocketServer;

    public static Start() {
        if (this.wss) {
            return;
        }

        this.wss = new WebSocketServer({ port: 8082 });

        this.wss.on('connection', (ws: any) => {
            this.OnConnected(ws);
            ws.on('close', () => { this.OnDisconnected(ws); });
        });
    }

    public static OnConnected(ws: WebSocket) {
        console.log('New client connected!');
        this.connections.push(ws);
    }

    public static OnDisconnected(ws: WebSocket) {
        console.log('Client has disconnected');
        this.connections.splice(this.connections.indexOf(ws), 1);
    }

    public static Send(message: string) {
        this.connections.forEach((ws: any) => {
            ws.send(message);
        });
    }
}