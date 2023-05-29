import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getTableData from '@salesforce/apex/HDT_LC_OrderDossierWizardTable.getTableData';
import next from '@salesforce/apex/HDT_LC_OrderDossierWizardTable.next';
import edit from '@salesforce/apex/HDT_LC_OrderDossierWizardTable.edit';
import cancel from '@salesforce/apex/HDT_LC_ChildOrderProcessActions.cancel';

export default class hdtOrderDossierWizardTable extends NavigationMixin(LightningElement) {

    @api orderParentRecord;
    orderId = '';
    action = '';
    loading = false;
    childOrdersList = [];
    orderItemList = [];
    currentStep = 2;
    isDialogVisible = false;

    get hiddenEdit(){
        let result = true;
        if(this.orderParentRecord.Step__c <= this.currentStep){
            result = true;
        } else if(this.orderParentRecord.Step__c > this.currentStep){
            result = false;
        }

        return result;
    }

    get disabledNext(){
        let result = false;
        console.log('#Order Parent Step >>> ' + this.orderParentRecord.Step__c)
        if(this.orderParentRecord.Step__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get disabledInput(){
        let result = false;
        console.log('#Order Parent Step >>> ' + this.orderParentRecord.Step__c)
        if(this.orderParentRecord.Step__c != this.currentStep){
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    get cancellationOptions() {
        return [
            { label: 'Pratica errata', value: 'Pratica errata' },
            { label: 'Annullamento da cliente', value: 'Annullamento da cliente' }
        ];
    }

    get columnsDocumenti(){
        return [
            {
                label: 'Numero Ordine',
                sortable: false,
                type: 'button',
                typeAttributes:{
                    variant: 'base',
                    style:'border: none;background: none',
                    label: {fieldName: 'OrderNumber'},
                    name: 'redirectOrder'
                }
            },
            /*{fieldName: 'CustomerName__c', // This field should have the actual URL in it.
             type: 'url', 
             sortable: "false",
             label: 'Numero Ordine',
             typeAttributes: {
                 label: {
                     fieldName: 'OrderNumber' 
                     // whatever field contains the actual label of the link
                 },
                 target: '_parent', 
                 tooltip: 'Open the customer page'
             }},*/
            {label: 'Codice punto', fieldName: 'pod', type: 'text'},
            {label: 'Indirizzo di fornitura', fieldName: 'SupplyAddressFormula__c', type: 'text'},
            {label: 'Phase', fieldName: 'Phase__c', type: 'text'},
            {label: 'Processo', fieldName: 'recordtypename', type: 'text'},
            {label: 'Offerta', fieldName: 'offerta', type: 'text'},
            {type:  'button',typeAttributes:{
                    iconName: 'utility:edit',
                    label: 'Avvia Processo', 
                    name: 'Avvia Processo', 
                    title: 'Avvia Processo',
                    disabled: {fieldName :'disabledActionButton'},
                    value: 'Avvia Processo'
                }
            },
            {type:  'button',typeAttributes:{
                    iconName: 'utility:delete',
                    label: 'Annulla',
                    name: 'cancelOrder',
                    title: 'Annulla',
                    disabled: {fieldName :'disabledCancellationActionButton'},
                    value: 'cancelOrder'
                }
            }
        ];
    };

    @api
    setTableData(){
        this.loading = true;
        setTimeout(() =>{
            getTableData({orderParentId: this.orderParentRecord.Id}).then(data =>{

                this.loading = false;
                
                this.childOrdersList = data.childOrdersList;// let orderList = results.orderList;
                this.orderItemList = data.orderItemList;

                this.childOrdersList.forEach(ord => {
                    if(ord.RecordType){
                        ord.recordtypename = ord.RecordType.Name;
                    }
                    ord.pod = '';
                    //ord.CustomerName__c = '/lightning/r/Order/' + ord.Id + '/view';
                    ord.pod = ord.ServicePoint__c !== undefined ? ord.ServicePoint__r.ServicePointCode__c : '';
                    ord.disabledCancellationActionButton = this.disabledInput || ord.Step__c === 20 || ord.Phase__c === 'Annullato' || ord.recordtypename === 'Default';
                    ord.disabledActionButton = this.disabledInput || ord.Step__c === 20 || ord.Phase__c === 'Annullato';
                    ord.offerta = data.primeQuoteLineMap[ord.Id]

                });

                console.log('this.childOrdersList: ', JSON.parse(JSON.stringify(this.childOrdersList)));

            }).catch(error => {
                this.loaded = true;
                const toastErrorMessage = new ShowToastEvent({
                    title: 'Errore',
                    message: error.message,
                    variant: 'error'
                });
                this.dispatchEvent(toastErrorMessage);
            });
        }, 3000);
    }

    handleRowAction(event){

        let row = event.detail.row;
        let action = event.detail.action;
        this.orderId = row.Id;
        this.action = action.value;
        let actionName = action.name;

        console.log('#Action Name >>> ' + actionName);

        if(this.action === 'cancelOrder'){
            this.isDialogVisible = true;
        }
        else if(actionName === 'redirectOrder')
        {
            console.log('#Action value >>> ' + JSON.stringify(row.Id));
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    objectApiName: 'Order', // objectApiName is optional
                    actionName: 'view'
                }
            });
        } else {
            console.log(' c__orderParent:'+ this.orderParentRecord.Id);
            console.log('  c__orderId:'+ this.orderId);
            console.log('  action:'+ this.action);



            this.dispatchEvent(new CustomEvent('handlerowactionevent', {
                detail:{
                    c__orderParent: this.orderParentRecord.Id,
                    c__orderId: this.orderId,
                    action: this.action
                }
            }));
            console.log();
        }

    }

    connectedCallback(){
        console.log('@@@@@@@@@id : '+this.orderParentRecord.id);
        this.setTableData();
    }

    handleNext(){
        this.loading = true;
        next({orderUpdates: {Id:this.orderParentRecord.Id}}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('orderrefresh', { bubbles: true }));
        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleEdit(){
        this.loading = true;
        edit({orderParentId:this.orderParentRecord.Id}).then(data =>{
            this.loading = false;
            this.dispatchEvent(new CustomEvent('orderrefresh', { bubbles: true }));
        }).catch(error => {
            this.loading = false;
            console.log((error.body.message !== undefined) ? error.body.message : error.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: (error.body.message !== undefined) ? error.body.message : error.message,
                variant: 'error'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    callCancel(cancellationReason){
        this.loading = true;
        cancel({order: {Id: this.orderId}, cancellationReason: cancellationReason}).then(data =>{
            this.loading = false;

            this.dispatchEvent(new CustomEvent('redirecttoparent'));

            const toastSuccessMessage = new ShowToastEvent({
                title: 'Successo',
                message: 'Processo annullato con successo',
                variant: 'success'
            });
            this.dispatchEvent(toastSuccessMessage);

        }).catch(error => {
            this.loading = false;

            let errorMessage = '';

            if (error.body.message !== undefined) {
                errorMessage = error.body.message;
            } else if(error.message !== undefined){
                errorMessage = error.message;
            } else if(error.body.pageErrors !== undefined){
                errorMessage = error.body.pageErrors[0].message;
            }

            console.log('Error: ', errorMessage);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    handleCancel(){
        this.isDialogVisible = true;
    }

    handleDialogResponse(event){
        if(event.detail.status == true){

            this.callCancel(event.detail.choice);

        } else {
            this.isDialogVisible = false;
        }
    }
}