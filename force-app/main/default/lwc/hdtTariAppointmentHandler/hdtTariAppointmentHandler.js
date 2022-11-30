import { LightningElement, api, track,wire } from 'lwc';
import getCase from '@salesforce/apex/HDT_LC_AppointmentTariAgenda.getCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import ID_FIELD from '@salesforce/schema/Case.Id';
import PHASE_FIELD from '@salesforce/schema/Case.Phase__c';

const OBJECT_FIELDS =[
    'Id',
    'Phase__c',
    'StartAppointment__c',
    'Outcome__c',
    'PhaseStory__c'
];

export default class HdtTariAppointmentHandler extends LightningElement{
    showAgenda = false;
    showForm = false;
    isRendered = true;
    hasRendered = false;
    variant='offline';
    alertMessage = 'Per prendere l\'appuntamento seleziona Prendi Appuntamento. Una volta confermato l\'appuntamento non sarà possibile modificarlo o annullarlo in autonomia ma sarà necessario contattare il servizio clienti. Ti ricordiamo che hai a disposizione 24 ore per prendere l\'appuntamento.';
    @api confirmed = false;
    @api isCommunity = false;
    @api recordId;
    isNotOwner;
    @track params={};
    @track isViewAppointmentEnabled = false; 
    
    @track tempList = [
        {label: 'Prendi Appuntamento ', name: 'newDate', iconName: 'utility:retail_execution', desc: 'Prendi un nuovo appuntamento con il DL', enable : false, visible : true},
        {label: 'Visualizza Appuntamento', name: 'viewDate', iconName: 'utility:record_lookup', desc: 'Visualizza il tuo appuntamento', enable : false, visible : true}
        // {label: 'Annulla Appuntamento', name: 'cancelDate', iconName: 'utility:record_delete', desc: 'Cancella il tuo appuntamento', enable : false, visible : true}
    ];
    
    get stmtValue(){
        return this.tempList;
    }

    @wire(getCase,{caseId : '$recordId', fields: OBJECT_FIELDS })
    wiredCase(value){
        this.wiredCase = value;
        const { data, error } = value; 
        console.log('value ->'+ value);
        if (data){
            this.case = data;
            console.log('case ->' + this.case);
            if(this.case.Outcome__c == 'Empty_Slots') {
                this.isRendered = false;
            }
            if(this.confirmed==false){
                this.tempList.forEach( item =>{
                    let itemName = item.name;
                    console.log('item -> ' + item);
                        switch (itemName){
                            case 'newDate':
                                if(this.case.Phase__c == 'In attesa Appuntamento') item.enable = true;
                            break;
                            case 'viewDate':
                                if(this.case.StartAppointment__c!= null && this.case.Phase__c != 'Completata' && this.case.Phase__c != 'Annullato'){
                                    item.visible = true;
                                    item.enable = true;
                                }
                            break;
                            // case 'cancelDate':
                            //     if(
                            //         this.case.Phase__c == 'Da Inviare' 
                            //         && this.case?.PhaseStory__c?.split(/\|\||@@/)?.some(str=>str?.toLowerCase()?.startsWith("in attesa appuntamento"))
                            //     ){
                            //         item.enable = true;
                            //     }
                            // break;
                        }
                });
            }
        }else if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
    }
    
    clickOperation(event){
        event.preventDefault();
        this.showAgendaForm(event.currentTarget.name);
    }

    showAgendaForm(btnName){
        console.log('btnName --> '+btnName);
        let showAgenda = true;
        switch (btnName){
            case 'newDate':
                this.params ={
                    method : 'handleSearch',
                    searchType : 'FirstSearch'
                };
            break;
            case 'viewDate':
                this.params ={
                    method : 'handleView',
                    searchType : 'View'
                };
            break;
            case 'cancelDate':
                showAgenda=false;
                this.updatePhase();
                break;
        }
        if (showAgenda){
            this.params = {...this.params,userCommunity : this.isCommunity};
            this.showAgenda = showAgenda;
        }else{
            //this.showForm = true;
        }

    }

    updatePhase(){
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[PHASE_FIELD.fieldApiName] = "Richiesto Annullamento";

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case aggiornato',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                if (this.isCommunity){
                    let myWiredCase = this.wiredCase;
                    setTimeout(function(){refreshApex(myWiredCase)},5000);
                }else{
                    window.location.reload();
                }
            })
            .catch(error => {
                let message = error.body?.output?.errors?.[0]?.message;
                message=message? message : error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Errore Aggiornamento Fase',
                        message: message,
                        variant: 'error'
                    })
                );
            });

    }

    cancelEvent(event){
        this.params = {};
        if(event.detail === true){
            if (this.isCommunity){
                let myWiredCase = this.wiredCase;
                setTimeout(function(){refreshApex(myWiredCase)},5000);
            }else{
                window.location.reload();
            }
        }else{
            this.showAgenda = false;
            this.showForm = false;
        }
        
    }

}