require('dotenv').config();
import * as tmi from 'tmi.js';
import Socket from './Socket';

export class Twitch {

    private static client: tmi.Client;

    private static list: Array<string> = [];

    public static Connect() {
        this.client = new tmi.Client({
            channels: ['lekkerspelen'],
            // No need for auth, we're just reading chat.
        });

        this.client.connect();

        this.client.on('message', (channel, tags, message) => {
            // Log message with this format: [yyyy-mm-dd hh:MM:ss UTC] name: message
            // console.log(`[${new Date().toISOString()}] ${tags.username}: ${message}`);
            if (!this.list.includes(tags.username)) {
                this.list.push(tags.username);
                console.log(`["${tags.username}]" = ${tags['badge-info']?.subscriber ?? '0'},`);
            }

            Socket.Send(JSON.stringify({
                user: tags.username,
                message: message,
                subscriber: parseInt(tags?.badges?.subscriber ?? '0')
            }));
        });
    }
}