import { LightningElement, api, track } from 'lwc';

export default class HdtInfoPointTable extends LightningElement 
{

    @track showInfoModal = false;

    handleClick(event)
    {
        event.preventDefault();
        this.showInfoModal = true;
    }
}