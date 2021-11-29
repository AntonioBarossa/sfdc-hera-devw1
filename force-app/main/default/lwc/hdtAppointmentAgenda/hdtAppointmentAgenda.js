import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleSearch from '@salesforce/apex/HDT_LC_AppointmentAgenda.handleSearch';
import handleCancellation from '@salesforce/apex/HDT_LC_AppointmentAgenda.handleCancellation';
import handleConfirm from '@salesforce/apex/HDT_LC_AppointmentAgenda.handleConfirm';
import { getRecord } from 'lightning/uiRecordApi';
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';

const OBJECT_FIELDS =[
    'wrts_prcgvr__Activity__c.MaxTimeModificationAppointment__c',
    'wrts_prcgvr__Activity__c.MaxDateModificationAppointment__c',
    'wrts_prcgvr__Activity__c.AppointmentCode__c',
    'wrts_prcgvr__Activity__c.AppointmentDuration__c',
    'wrts_prcgvr__Activity__c.AppoitmentTimeSlotConfirmed__c',
    'wrts_prcgvr__Activity__c.AppointmentDate__c',
    'wrts_prcgvr__Activity__c.AppointmentTimeSlotToConfirm__c',
    'wrts_prcgvr__Activity__c.AppointmentDateToConfirm__c',
    'wrts_prcgvr__Activity__c.wrts_prcgvr__Status__c'
    
];

const COLUMNS = [
    { label: 'Data appuntamento', fieldName: 'data', type: 'date' },
    { label: 'Fascia oraria', fieldName: 'fascia', type: 'text' },
    { label: 'Stima durata', fieldName: 'stima', type: 'text' },
    { label: 'Codice Appuntamento', fieldName: 'codice', type: 'text' },
    { label: 'Data limite modifica', fieldName: 'dataLimite', type: 'date' },
    { label: 'Ora limite validità', fieldName: 'oraLimite', type: 'text' }
];

const PREFERETIAL_TIME = [
    {label : '08:00/09:00' , value : '08:00/09:00'},
    {label : '09:00/10:00' , value : '09:00/10:00'},
    {label : '10:00/11:00' , value : '10:00/11:00'},
    {label : '11:00/12:00' , value : '11:00/12:00'},
    {label : '12:00/13:00' , value : '12:00/13:00'},
    {label : '13:00/14:00' , value : '13:00/14:00'},
    {label : '14:00/15:00' , value : '14:00/15:00'},
    {label : '15:00/16:00' , value : '15:00/16:00'},
    {label : '16:00/17:00' , value : '16:00/17:00'},
    {label : '17:00/18:00' , value : '17:00/18:00'},
    {label : '18:00/19:00' , value : '18:00/19:00'},
    {label : '19:00/20:00' , value : '19:00/20:00'}
];
 


export default class HdtAppointmentAgenda extends LightningElement {
    @api activityid;
    @api params;
    @track activity;
    @track columns = COLUMNS;
    @track records = [];
    disableConfirmButton = false;
    
    searchType;
    options = PREFERETIAL_TIME;
    newDateLabel;
    selectedCode;
    showSpinner = true;
    fieldsToRetrieve;


    @wire(getRecord,{recordId : '$activityid',fields : '$fieldsToRetrieve'})
    wireRecord({error,data}){
        if (error){
            console.log(error);
        }
        if (data && this.params){
            this.activity = data;
            let stato = this.activity.fields.wrts_prcgvr__Status__c.value;
            if (this.activity.fields.AppointmentCode__c.value && stato && stato.localeCompare('Presa appuntamento in corso') === 0){
                this.labelButton = 'Altre Date';
                this.addRecord({
                    codice : this.activity.fields.AppointmentCode__c.value,
                    data : this.activity.fields.AppointmentDateToConfirm__c.value,
                    fascia : this.activity.fields.AppointmentTimeSlotToConfirm__c.value,
                    stima: this.activity.fields.AppointmentDuration__c.value,
                    dataLimite : this.activity.fields.MaxDateModificationAppointment__c.value,
                    oraLimite : this.activity.fields.MaxTimeModificationAppointment__c.value
                });
            }else{
                this.labelButton = 'Cerca';
                this.disableConfirmButton = true;
            }
            switch (this.params.method){
                case 'handleSearch':
                    this.searchType = this.params.searchType;
                    this.showSpinner = false;
                    if (this.searchType.localeCompare('FirstSearch') === 0){
                        this.newDateLabel = 'Cerca';
                    }else {
                        this.newDateLabel = 'Altre Date';
                    }
                break;
                case 'handleCancellation':
                    this.deleteAppointment();
                break;
            }
        }
    }
    
    connectedCallback(){
        if (this.params){
            this.fieldsToRetrieve = OBJECT_FIELDS;
        }
    }

    confirmAppointment(){
        this.showSpinner = true;
        let row = this.template.querySelector('[data-id="dtAppointment"]').getSelectedRows();
        handleConfirm({
            activityId : this.activityid,
            appointmentCode : row[0].codice
        }).then(result =>{
            if (result === 'OK'){
                this.showAlert('Operazione Riuscita','L\'appuntamento è stato confermato','success');
                setTimeout(function(){window.location.reload();},3000);
            }else{
                this.showAlert('Errore',result,'error');
            }
        }).catch(error =>{
            this.showAlert('Errore',error.body.message,'error');
        });
    }

    deleteAppointment(){
        this.showSpinner = true;
        handleCancellation({
            activityId : this.activityid,
            appointmentCode : this.activity.fields.AppointmentCode__c.value
        }).then(result =>{
            if (result === 'OK'){
                this.showAlert('Operazione Riuscita','L\'appuntamento è stato annullato','success');
                setTimeout(function(){window.location.reload();},3000);
            }else{
                this.showAlert('Errore',result,'error');
            }
        }).catch(error =>{
            this.showAlert('Errore',error.body.message,'error');
        });
    }


    

    handleClick(event){
        if (event.target.name === 'Save'){
            if (this.isAppointmentSelected()){
                this.confirmAppointment();
            }else{
                this.showAlert('Attenzione','Selezionare un appuntamento','error');
            }
        }else if (event.target.name === 'Cancel'){
            this.showSpinner = true;
            this.dispatchEvent(new CustomEvent('cancelevent'));
        }else if (event.target.name === 'newDate'){
            this.getNewDate();
        }
    }

    getNewDate(){
        let appointment = this.template.querySelector('[data-id="newAppointment"]').value;
        let preferentialTime = this.template.querySelector('[data-id="preferentialTime"]').value;
        let errorMessage = this.checkForm(appointment,preferentialTime);
        if (errorMessage != ''){
            this.showAlert('Attenzione',errorMessage,'error');
        }else{
            this.handleSearchMethod(appointment,preferentialTime);
        }
        
        
    }

    handleSearchMethod(appointment,preferentialTime){
        this.showSpinner = true;
        handleSearch({
            activityId : this.activityid,
            searchType : this.searchType,
            preferedDate : appointment,
            preferedTimeSlot : preferentialTime
        }).then(result =>{
            let data = JSON.parse(result);
            if (data.error){
                this.showAlert('Attenzione',data.error,'error');
            }else{
                let slots = [];
                try{
                    slots = data.appuntamento;

                    slots.forEach(element => {
                        console.log('@@@@ element ' + JSON.stringify(element));
                        this.addRecord({
                            codice : element.codiceApp, 
                            data :new Date(element.appData), 
                            fascia : element.appFasciaOrario, 
                            stima: element.zStimaDurApp, 
                            dataLimite : new Date(element.zLimApp),
                            oraLimite : element.zLimAppOra 
                        });
                        this.disableConfirmButton = false;  
                    });
                }catch(e){
                    console.error(e);
                    this.showAlert('Attenzione','Errore nella chiamata al server. Non è stato ricevuto un appuntamento valido.','error');
                }
            }
            this.showSpinner = false;
            if (this.searchType.localeCompare('FirstSearch') === 0){
                this.searchType = 'NewSlot';
                this.newDateLabel = 'Altre Date';
            }
        }).catch(error =>{
            this.showSpinner = false;
            this.showAlert('Attenzione',error.body.message,'error');
        });
    }

    checkForm(appointment,preferentialTime){
        let message = '';
        if (!appointment){
            message = 'Inserire il campo "Data appuntamento preferenziale"';
        }else if(!preferentialTime){
            message = 'Inserire il campo "Fascia oraria preferenziale"';
        }else if(appointment && preferentialTime){
            let startTime = preferentialTime.split('/');
            let appointmentDateMs = new Date(appointment+' '+startTime[0]).getTime();
            let todayMs = (new Date()).getTime();
            if (appointmentDateMs <= todayMs){
                message = 'La data inserita è già scaduta';
            }
        }
        return message;
    }

    isAppointmentSelected(){
        try{
            let row = this.template.querySelector('[data-id="dtAppointment"]').getSelectedRows();
            if (row.length > 0 ){
                this.selectedCode = row.codice;
                return true;
            }else{
                return false;
            }
        }catch(e){
            console.error(e);
            return false;
        }
        
    }

    showAlert(_title,_message,_variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: _title,
                message: _message,
                variant: _variant
            })
        );
    }

    addRecord(element){
        this.records = [...this.records,element];
    }
}