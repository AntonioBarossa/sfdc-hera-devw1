import { LightningElement, api, track } from 'lwc';

export default class HdtInfoPointTable extends LightningElement 
{

   
    @api columnsObj = [];
    @api infoObj = [];
    @api keyField = '';
    @api modalHeader = '';
    @api loadingSpinner = false;
    
    @track showInfoModal = false;

    handleClick(event)
    {
        event.preventDefault();
        this.showInfoModal = true;
        const openEvent = new CustomEvent('openmodal');
        this.dispatchEvent(openEvent);
    }
    handleClose(event)
    {
        event.preventDefault();
        this.showInfoModal = false;
    }
}