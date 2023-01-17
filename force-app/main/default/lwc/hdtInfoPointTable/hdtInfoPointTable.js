import { LightningElement, api, track } from 'lwc';

export default class HdtInfoPointTable extends LightningElement 
{

   
    @api columnsObj = [];
    @api infoObj = [];
    @api fieldKey = '';
    @api modalHeader = '';
    @api loadingSpinner = false;
    @api infoDisabled = false;
    
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