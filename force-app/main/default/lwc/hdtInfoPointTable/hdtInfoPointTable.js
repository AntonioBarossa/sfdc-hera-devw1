import { LightningElement, api, track } from 'lwc';

export default class HdtInfoPointTable extends LightningElement 
{

   
    @api columnsObj = [{label: 'Driver', fieldName: 'driverName'},{label: 'Valore', fieldName: 'driverValue'}];
    @api infoObj = [{driverName: 'Stato Contratto', driverValue: 'Cessato'},{driverName:'Presenza Allaccio', driverValue: 'Si'}];
    @api keyField = 'driverName';
    @api modalHeader = 'Matrice Processi';
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