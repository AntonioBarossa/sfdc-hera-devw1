import { LightningElement, api, track,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAct from '@salesforce/apex/HDT_LC_CommunicazioniDistributore.createActivity';
import { refreshApex } from '@salesforce/apex';

export default class HdtComunicazioniDistributore extends LightningElement {
    
    showSpinner=false;
    tipo;
    @api recordId;
    
    @track tempList = [
        {label: 'Sollecito Distributore', name: 'solDis', iconName: 'utility:retail_execution', enable : true, visible : true},
        {label: 'Annullamento', name: 'annulla', iconName: 'utility:record_delete', enable : true, visible : true},
        {label: 'Anticipo Appuntamento', name: 'antApp', iconName: 'utility:retail_execution', enable : true, visible : true},
        {label: 'Riaperture urgenti errori DL', name: 'errDL', iconName: 'utility:retail_execution', enable : true, visible : true},
        {label: 'Richiesta informazioni appuntamento', name: 'infoApp', iconName: 'utility:retail_execution', enable : true, visible : true},
        {label: 'Richiesta appuntamento DL (fermo sistemi)', name: 'ricAppDL', iconName: 'utility:retail_execution', enable : true, visible : true},
        {label: 'Comunicazione da DL', name: 'comDL', iconName: 'utility:retail_execution', enable : true, visible : true}
    ];
    @track params={};
    get stmtValue(){
        return this.tempList;
    }

    clickOperation(event){
        this.showSpinner=true;
        switch (event.currentTarget.name){
            case 'solDis':
                this.tipo='Sollecito Distributore';
            break;
            case 'annulla':
                this.tipo='Annullamento';
            break;
            case 'antApp':
                this.tipo='Anticipo Appuntamento';
            break;
            case 'errDL':
                this.tipo='Riaperture urgenti errori DL';
            break;
            case 'infoApp':
                this.tipo='Richiesta informazioni appuntamento';
            break;
            case 'ricAppDL':
                this.tipo='Richiesta appuntamento DL (fermo sistemi)';
            break;
            case 'comDL':
                this.tipo='Comunicazione da DL';
            break;
        }
        console.log('kkk '+this.tipo);
        createAct({recordId: this.recordId, type: this.tipo}).then((data) => {
            console.log('@@Data: '+data);
            if (data == 'ok'){
                this.showSuccessToast();
                this.showSpinner=false;
                this.closeQuickAction();
            }else{
                console.log('in else');
                this.showErrorToast();
                this.showSpinner=false;
            }
        }).catch((error) => {
            console.error(error);
            this.showErrorToast();
            this.showSpinner=false;
        })
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Nuova Attività creata correttamente',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Errore',
            message: 'Non è stato possibile creare una nuova Attività',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}