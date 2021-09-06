import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtManageProductAssociation extends NavigationMixin(LightningElement) {

    @api productid;
    showWelcom = false;
    showSearchOffer = false;
    showCreateRecord = false;
    showSearchTable = false;
    template;
    showError = false;
    errorHeader = '';
    errorMessage = '';

    errorHeader = 'Associazione';
    errorMessage = '';

    label = {
        mainTitle: 'Associazione',
        associationTitleLabel: 'Associazione massiva del Prodotto Opzione',
        deleteTitleLabel: 'Rimozione massiva del Prodotto Opzione'
    };

    connectedCallback(){
        console.log('#### productid > ' + this.productid);

    }

    @wire(getRecord, { recordId: '$productid', fields: ['Product2.Family'] })
    wiredProduct({ error, data }) {
        if (data) {
            console.log('#### Family -> ' + data.fields.Family.value);
            
            if(data.fields.Family.value.includes("Bonus") ||
               data.fields.Family.value.includes("Contributo") ||
               data.fields.Family.value.includes("VAS") ||
               data.fields.Family.value.includes("Promozione")){
                this.showWelcom = true;
            } else {
                this.showError = true;
                this.errorMessage = 'Questa funzionalità è riservata a Bonus, Contributi, VAS, Promozioni';
            }

        } else if (error) {
            for(var key in error){
                console.log('# Error -> ' + key + ' - ' + error[key]);
            }
            
        }
    }

    handleClick(event){
        console.log('### productid -> ' + this.productid);
    }

    closeModal(event){
        console.log('### Parent closeModal ###');
        console.log('### return to-> ' + this.productid);

        const goback = new CustomEvent('goback', {
            detail: {prodId: this.productid}
        });
        // Fire the custom event
        this.dispatchEvent(goback);
        this.goToRecord(this.productid, 'Product2');

    }

    createNew(event){
        console.log('### Parent createNew ###');
        this.showWelcom = false;
        this.showCreateRecord = true;
    }

    search(event){
        console.log('### Parent search ###');
        this.showWelcom = false;
        this.showCreateRecord = true;
    }

    closeSearch(event){
        this.showWelcom = true;
        this.showSearchOffer = false;
        
        console.log('### return to-> ' + this.productid);
        this.goToRecord(this.productid, 'Product2');

    }

    saveRecord(event){
        console.log('>>> RECORD CONFIGURED -> ' + event.detail.record);
        this.showSearchTable = true;
        this.showWelcom = false;
        this.showCreateRecord = false;
    }

    goToRecord(recId, objName){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objName,
                actionName: 'view'
            }
        });
    }

}