import { LightningElement } from 'lwc';

export default class HdtCtToolbarContainer extends LightningElement {
    
    showPanel = true;
    numberToCall = '';

    toolbarEvent(event){
        console.log('>>> toolbarEvent');
        console.log('>>> EVENT TYPE > ' + event.detail.eventType);
        console.log('>>> EVENT OBJ > ' + JSON.stringify(event.detail.eventObj));
    }

    callThisNumber(){
        this.template.querySelector("c-hdt-ct-toolbar").callNumberFromParent(this.numberToCall);
    }

    hangup(){
        this.template.querySelector("c-hdt-ct-toolbar").hangUpFromParent();
    }

}