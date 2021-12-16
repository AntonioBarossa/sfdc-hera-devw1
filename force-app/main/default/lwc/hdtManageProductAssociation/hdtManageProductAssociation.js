import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

import cl_CreateTitle from '@salesforce/label/c.ProdOptAssociationCreateTitle';
import cl_DeleteTitle from '@salesforce/label/c.ProdOptAssociationDeleteTitle';
import cl_DeleteSection from '@salesforce/label/c.ProdOptAssociationDeleteSection';
import cl_CreateSection from '@salesforce/label/c.ProdOptAssociationCreateSection';
import cl_ConfirmSelection from '@salesforce/label/c.ProdOptAssociationConfirmSelection';
import cl_Close from '@salesforce/label/c.ProdOptAssociationClose';
import cl_CloseDeleteBody from '@salesforce/label/c.ProdOptAssociationCloseDeleteBody';
import cl_CloseCreateBody from '@salesforce/label/c.ProdOptAssociationCloseCreateBody';
import cl_ConfimSelectBody from '@salesforce/label/c.ProdOptAssociationConfimSelectBody';
import cl_ConfirmFilterTitle from '@salesforce/label/c.ProdOptAssociationConfirmFilterTitle';
import cl_ConfirmFilterDeleteBody from '@salesforce/label/c.ProdOptAssociationConfirmFilterDeleteBody';
import cl_ConfirmFilterCreateBody from '@salesforce/label/c.ProdOptAssociationConfirmFilterCreateBody';
import cl_ConfimSelectBodyDelete from '@salesforce/label/c.ProdOptAssociationConfimSelectBodyDelete';
import cl_ResultText from '@salesforce/label/c.ProdOptAssociationResultText';
import cl_NoResultText from '@salesforce/label/c.ProdOptAssociationNoResultText';

export default class HdtManageProductAssociation extends NavigationMixin(LightningElement) {

    tableLabels = {
        cl_CreateTitle,
        cl_DeleteTitle,
        cl_DeleteSection,
        cl_CreateSection,
        cl_ConfirmSelection,
        cl_Close,
        cl_CloseDeleteBody,
        cl_CloseCreateBody,
        cl_ConfimSelectBody,
        cl_ConfirmFilterTitle,
        cl_ConfirmFilterDeleteBody,
        cl_ConfirmFilterCreateBody,
        cl_ConfimSelectBodyDelete,
        cl_ResultText,
        cl_NoResultText
    };

    @api recordid;
    objApiName = 'SBQQ__ProductOption__c';
    recordData;
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
        console.log('>>> PRODUCT OPTION Id: ' + this.recordid);
    }

    @wire(getRecord, { recordId: '$recordid', fields: ['Product2.Name', 'Product2.Family', 'Product2.Status__c'] })
    wiredProduct({ error, data }) {
        if (data) {
            console.log('>>> PRODUCT OPTION Family -> ' + data.fields.Family.value);
            console.log('>>> PRODUCT OPTION Status -> ' + data.fields.Status__c.value);
            console.log('>>> PRODUCT OPTION Name -> ' + data.fields.Name.value);
            
            var notAvailableType = ['Offerta commerciale'];//, 'VAS Prodotto', 'VAS Servizio'];
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

            this.recordData = data;

        } else if (error) {
            for(var key in error){
                console.log('# Error -> ' + key + ' - ' + error[key]);
            }
        }
    }

    handleClick(event){
        console.log('### recordid -> ' + this.recordid);
    }

    closeModal(event){
        console.log('### Parent closeModal ###');
        console.log('### return to-> ' + this.recordid);

        const goback = new CustomEvent('goback', {
            detail: {prodId: this.recordid}
        });
        // Fire the custom event
        this.dispatchEvent(goback);
        this.goToRecord(this.recordid, 'Product2');

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
        
        console.log('### return to-> ' + this.recordid);
        this.goToRecord(this.recordid, 'Product2');

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