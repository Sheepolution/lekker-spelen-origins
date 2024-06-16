require('dotenv/config');
import './Utils/custom';
import Socket from './Providers/Socket';
import { Twitch } from './Providers/Twitch';

Socket.Start();
Twitch.Connect();