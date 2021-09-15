import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtManageProductAssociation extends NavigationMixin(LightningElement) {

    @api productid;
    productOptionId;
    productOptionObj;
    showWelcom = false;
    showSearchOffer = false;
    showCreateRecord = false;
    showSearchTable = false;
    template;
    showError = false;
    errorHeader = '';
    errorMessage = '';
    dmlContext;

    errorHeader = 'Associazione';
    errorMessage = '';

    label = {
        mainTitle: 'Associazione',
        associationTitleLabel: 'Associazione massiva del Prodotto Opzione',
        deleteTitleLabel: 'Rimozione massiva del Prodotto Opzione'
    };

    enableCreate = false;
    enableDelete = false;

    connectedCallback(){
        console.log('>>> PRODUCT OPTION Id: ' + this.productid);
    }

    @wire(getRecord, { recordId: '$productid', fields: ['Product2.Family', 'Product2.Status__c'] })
    wiredProduct({ error, data }) {
        if (data) {
            console.log('>>> PRODUCT OPTION Family -> ' + data.fields.Family.value);
            console.log('>>> PRODUCT OPTION  status -> ' + data.fields.Status__c.value);
            
            var notAvailableType = ['Offerta commerciale', 'VAS Prodotto', 'VAS Servizio'];
            var availableStatusForCreation = ['In Sviluppo', 'Confermata', 'Vendibile', 'Scaduta'];
            var availableStatusForDeletion = ['In Sviluppo', 'Confermata'];

            if(availableStatusForCreation.includes(data.fields.Status__c.value)){
                this.enableCreate = true;
            }

            if(availableStatusForDeletion.includes(data.fields.Status__c.value)){
                this.enableDelete = true;
            }

            if(notAvailableType.includes(data.fields.Family.value)){
                this.showError = true;
                this.errorMessage = 'Questa funzionalità è riservata a Bonus, Contributi, VAS, Promozioni';
            } else {
                this.showWelcom = true;
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

    createAssociation(event){
        console.log('### Parent createAssociation ###');
        this.dmlContext = 'insert';
        this.showWelcom = false;
        this.showCreateRecord = true;
    }

    deleteAssociation(event){
        console.log('### Parent deleteAssociation ###');
        this.dmlContext = 'delete';
        this.showWelcom = false;
        //this.showCreateRecord = true;
        this.showSearchTable = true;
    }

    closeSearch(event){
        this.showWelcom = true;
        this.showSearchOffer = false;
        
        console.log('### return to-> ' + this.productid);
        this.goToRecord(this.productid, 'Product2');

    }

    saveRecord(event){
        //console.log('>>> RECORD CONFIGURED -> ' + event.detail.productOptionId);
        //this.productOptionId = event.detail.productOptionId;
        
        console.log('>>> RECORD CONFIGURED -> ' + event.detail.productOptionObj);
        this.productOptionObj = event.detail.productOptionObj;

        this.showCreateRecord = false;
        this.showSearchTable = true;
    }

    closeEditForm(event){
        this.showCreateRecord = false;
        this.showWelcom = true;
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