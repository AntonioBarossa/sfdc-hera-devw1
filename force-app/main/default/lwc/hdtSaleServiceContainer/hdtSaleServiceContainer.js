import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSaleServiceItemTile from '@salesforce/apex/HDT_LC_SaleServiceContainer.createSaleServiceItemTile';

export default class hdtSaleServiceContainer extends LightningElement {
    @api saleRecord;
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    servicePoint;

    @api
    refreshTileData(){
        this.template.querySelector('c-hdt-sale-service-items-tiles').getTilesData();
    }

    handleNewServicePoint(event){
        let newServicePoint = event.detail;
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: {newServicePoint}}));
    }

    handleConfirmServicePointEvent(event){
        console.log('hdtSaleServiceContainer: ',JSON.parse(JSON.stringify(event.detail)));
        this.servicePoint = event.detail;

        console.log('servicePoint:', JSON.stringify(this.servicePoint));
        console.log('sale: ', JSON.stringify(this.saleRecord));

        createSaleServiceItemTile({servicePoint:this.servicePoint, sale:this.saleRecord}).then(data =>{

            this.refreshTileData();
            this.dispatchEvent(new CustomEvent('newtile'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Service Point confermato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });

    }

    handleTileDeleteEvent(){
        this.dispatchEvent(new CustomEvent('tiledelete'));
    }
}