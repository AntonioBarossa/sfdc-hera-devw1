import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSaleServiceItemTile from '@salesforce/apex/HDT_LC_SaleServiceContainer.createSaleServiceItemTile';
import updateSale from '@salesforce/apex/HDT_LC_SaleServiceContainer.updateSale';
import fieldsTransition from '@salesforce/apex/HDT_UTL_OrderProcessAssignment.fieldsTransition';


export default class hdtSaleServiceContainer extends LightningElement {
    @api saleRecord;
    @api processType;
    @api accountId;
    @api targetObject;
    @api addititionalParam;
    @track servicePoint;
    currentStep = 2;
    nextStep = 3;
    loading = false;

    get hiddenEdit(){
        let result = true;
        if(this.saleRecord.CurrentStep__c <= this.currentStep){
            result = true;
        } else if(this.saleRecord.CurrentStep__c > this.currentStep){
            result = false;
        }

        return result;
    }

    get disabledNext(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledInput(){
        let result = false;
        if(this.saleRecord.CurrentStep__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    @api
    refreshTileData(){
        this.template.querySelector('c-hdt-sale-service-items-tiles').getTilesData();
    }

    handleNewServicePoint(event){
        let newServicePoint = event.detail;
        this.servicePoint = newServicePoint;
        this.dispatchEvent(new CustomEvent('newservicepoint', {detail: {newServicePoint}}));
    }

    handleConfirmServicePointEvent(event){

        this.loading = true;
        if(event.detail.newServicePoint !== undefined) {
            this.servicePoint = event.detail.newServicePoint;
        }
        else {
            this.servicePoint = event.detail;
        }

        let oldSupplyType = '';

        if(event.detail.oldSupplyType !== undefined) {
            oldSupplyType = event.detail.oldSupplyType;
        }

        createSaleServiceItemTile({servicePoint:this.servicePoint, sale:this.saleRecord, oldSupplyType: oldSupplyType}).then(data =>{

            this.refreshTileData();
            this.dispatchEvent(new CustomEvent('newtile'));
            if(data.isTransition && data.message === false){
                const toastWarning = new ShowToastEvent({
                    title: 'Warning',
                    message: 'E stato creato un caso transitorio!',
                    variant: 'warning'
                });
                this.dispatchEvent(toastWarning);
    
            }
            else if(data.isTransition && data.message === true)
            {
                const toastWarning = new ShowToastEvent({
                    title: 'Warning',
                    message: 'E stato creato un caso transitorio! Verrà creata un\'activity di tracciamento per il caricamento della vendita in Siebel',
                    variant: 'warning'
                });
                this.dispatchEvent(toastWarning);
            }
            else{
                const toastSuccessMessage = new ShowToastEvent({
                    title: 'Successo',
                    message: 'Service Point confermato con successo',
                    variant: 'success'
                });
                this.dispatchEvent(toastSuccessMessage);
    

            }

            this.loading = false;
            
        }).catch(error => {
            this.loading = false;
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

    updateSaleRecord(saleData){
        this.loading = true;
        updateSale({sale: saleData}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('saleupdate', { bubbles: true }));
        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleNext(){
        this.loading = true;
        /**TK 944536C - softening del controllo di entrata Subentro_Remi in quanto per piu' punti potrebbe uscire Subentro_Remi_Remi ecc. */
        fieldsTransition({sale: this.saleRecord}).then(data =>{
            if(data == null || data == '' ||  data == 'Subentro' || data.indexOf('Subentro_Remi') > -1 || data == '_Remi'){
                if(data == 'Subentro' || data.indexOf('Subentro_Remi') > -1){
                    const toastErrorMessage = new ShowToastEvent({
                        title: 'warning',
                        message: 'Per i punti di fornitura gas se si tratta di Subentro ricordarsi di prendere l\'appuntamento su Siebel oppure annullare la vendita ed inserire la richiesta su Siebel.',
                        variant: 'warning'
                    });
                    this.dispatchEvent(toastErrorMessage);
                }
                if(data == '_Remi' || data == 'Subentro_Remi'){
                    const toastErrorMessage2 = new ShowToastEvent({
                        title: 'warning',
                        message: 'Non è Stato Possibile Calcolare i Codici Remi per i PDR di riferimento',
                        variant: 'warning'
                    });
                    this.dispatchEvent(toastErrorMessage2);
                }
                //this.dispatchEvent(toastErrorMessage);
                this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.nextStep});  
            }
            else if(data == 'Remi'){
                const toastErrorMessage = new ShowToastEvent({
                    title: 'warning',
                    message: 'Non è Stato Possibile Calcolare i Codici Remi per i PDR di riferimento',
                    variant: 'warning'
                });
                this.dispatchEvent(toastErrorMessage);
                this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.nextStep});  
            }else{
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: 'Transitorio:  A causa dei seguenti Punti Di Fornitura: ' + data + ' non è possibile procedere con la vendita.\n'
                    + ' Per le vendite a transitorio non è possibile innescare i processi: "Connessione con Attivazione" (Presenza Allaccio NO),\n '
                    + '"Temporanea - Nuova Attivazione" (Presenza Allaccio NO) e "Prima Attivazione con Modifica" (Potenza richiesta diversa da Potenza Contrattuale).',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toastErrorMessage);
            
            }
            this.loading = false;

        }).catch(error => {
            this.loading = false;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleEdit(){
        this.updateSaleRecord({Id: this.saleRecord.Id, CurrentStep__c: this.currentStep});
    }
}