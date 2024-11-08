import { Injectable } from '@angular/core';
import { Socket } from 'ngx-socket-io';
import { environment } from '../environments/environment';

@Injectable()
export class MeTubeSocket extends Socket {
  constructor() {
    super({
      url: environment.socketUrl,
      options: {
        path: environment.socketPath,
        transports: ['websocket', 'polling'],
        reconnection: true,
        reconnectionAttempts: 5,
        reconnectionDelay: 1000,
        reconnectionDelayMax: 5000,
        timeout: 20000,
        autoConnect: true
      }
    });
  }
}
