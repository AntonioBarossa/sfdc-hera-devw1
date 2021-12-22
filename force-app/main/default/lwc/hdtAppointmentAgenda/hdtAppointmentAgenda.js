import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handleSearch from '@salesforce/apex/HDT_LC_AppointmentAgenda.handleSearch';
import handleCancellation from '@salesforce/apex/HDT_LC_AppointmentAgenda.handleCancellation';
import handleConfirm from '@salesforce/apex/HDT_LC_AppointmentAgenda.handleConfirm';
import getActivity from '@salesforce/apex/HDT_LC_AppointmentAgenda.getActivity';

const OBJECT_FIELDS =[
    'MaxTimeModificationAppointment__c',
    'MaxDateModificationAppointment__c',
    'AppointmentCode__c',
    'AppointmentDuration__c',
    'AppoitmentTimeSlotConfirmed__c',
    'AppointmentDate__c',
    'AppointmentTimeSlotToConfirm__c',
    'AppointmentDateToConfirm__c',
    'wrts_prcgvr__Status__c'
];

const COLUMNS = [
    { label: 'Data appuntamento', fieldName: 'data', type: 'text' },
    { label: 'Fascia oraria', fieldName: 'fascia', type: 'text' },
    { label: 'Stima durata', fieldName: 'stima', type: 'text' },
    { label: 'Codice Appuntamento', fieldName: 'codice', type: 'text' },
    { label: 'Data limite modifica', fieldName: 'dataLimite', type: 'text' },
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
    refreshRecord = false;
    disableConfirmButton = false;
    isCommunity = false;
    searchType;
    options = PREFERETIAL_TIME;
    newDateLabel;
    selectedCode;
    showSpinner = true;
    fieldsToRetrieve;


    @wire(getActivity,{activityId : '$activityid',fields : '$fieldsToRetrieve'})
    wireRecord({error,data}){
        if (error){
            console.error('status error: ' + error.status);
            console.error('status body: ' + JSON.stringify(error.body));
        }
        if (data && this.params){
            this.activity = JSON.parse(data);
            let stato = this.activity.wrts_prcgvr__Status__c;
            if (this.activity.AppointmentCode__c && stato && stato.localeCompare('Presa appuntamento in corso') === 0){
                this.labelButton = 'Altre Date';
                /* this.addRecord({
                    codice : this.activity.AppointmentCode__c,
                    data : this.activity.AppointmentDateToConfirm__c,
                    fascia : this.activity.AppointmentTimeSlotToConfirm__c,
                    stima: this.activity.AppointmentDuration__c,
                    dataLimite : this.activity.MaxDateModificationAppointment__c,
                    oraLimite : this.activity.MaxTimeModificationAppointment__c
                }); */
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
                        let defaultValue = this.getDataValueForSearch(this.activity.AppointmentDateToConfirm__c,this.activity.AppointmentTimeSlotToConfirm__c,this.searchType);
                        this.handleSearchMethod(defaultValue.data,defaultValue.slot);
                        this.newDateLabel = 'Altre Date';
                    }
                break;
                case 'handleCancellation':
                    this.deleteAppointment();
                break;
            }
            this.refreshRecord = false;
        }
    }
    
    connectedCallback(){
        if (this.params){
            if (this.params.userCommunity === true){
                this.isCommunity = true;
            }
            this.fieldsToRetrieve = OBJECT_FIELDS;
        }
    }

    confirmAppointment(){
        this.showSpinner = true;
        let row = this.template.querySelector('[data-id="dtAppointment"]').getSelectedRows();
        handleConfirm({
            activityId : this.activityid,
            appointmentJson : JSON.stringify(row[0])
        }).then(result =>{
            if (!result){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else if (result.localeCompare('OK') === 0){
                this.showAlert('Operazione Riuscita','L\'appuntamento è stato confermato','success');
                this.refreshPage(this.isCommunity);
            }else if (result.localeCompare('ERRORE CONFERMA') === 0){
                this.showAlert('Errore','Impossibile confermare l\'appuntamento selezionato','error');
                this.showSpinner = false;
            }
        }).catch(error =>{
            this.showAlert('Errore',error.body.message,'error');
            this.dispatchEvent(new CustomEvent('cancelevent',{detail : this.refreshRecord}));
        });
    }

    deleteAppointment(){
        this.showSpinner = true;
        handleCancellation({
            activityId : this.activityid,
            appointmentCode : this.activity.AppointmentCode__c
        }).then(result =>{
            if (!result){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else if (result === 'OK'){
                this.showAlert('Operazione Riuscita','L\'appuntamento è stato annullato','success');
                this.refreshPage(this.isCommunity);
            }else{
                this.showAlert('Errore',result,'error');
                this.dispatchEvent(new CustomEvent('cancelevent',{detail : this.refreshRecord}));
            }
        }).catch(error =>{
            this.showAlert('Errore',error.body.message,'error');
            this.dispatchEvent(new CustomEvent('cancelevent',{detail : this.refreshRecord}));
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
            this.closeModal();
        }else if (event.target.name === 'newDate'){
            this.getNewDate();
        }
    }

    closeModal(){
        this.showSpinner = true;
        this.dispatchEvent(new CustomEvent('cancelevent',{detail : this.refreshRecord}));
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
            if (!result){
                this.showAlert('Attenzione','Nessuna risposta dal server.','error');
                this.showSpinner = false;
            }else if (result.localeCompare('ERRORE MODIFICA') === 0){
                this.showAlert('Attenzione','Non è possibile modificare l\'appuntamento.','error');
                this.showSpinner = false;
            }else if (result.localeCompare('COMPETENZA DISTRIBUTORE') === 0){
                let messaggio = this.isCommunity? 'Non è possibile proseguire con la prenotazione mediante questa procedura, poichè l\'appuntamento è in carico del distributore che la conttatterà per fissare un appuntamento.' :'L\'appuntamento è in carico al distributore, non è possibile proseguire con l\'azione effettuata.';
                this.showAlert('Attenzione',messaggio,'error');
                this.refreshPage(this.isCommunity);
            }else{
                let data = JSON.parse(result);
                let slots = [];
                try{
                    slots = data.appuntamento;

                    slots.forEach(element => {
                        this.addRecord({
                            codice : element.codiceApp, 
                            data : this.formatData(element.appData), 
                            fascia : element.appFasciaOrario, 
                            stima: element.zStimaDurApp, 
                            dataLimite : this.formatData(element.zLimApp),
                            oraLimite : element.zLimAppOra 
                        });
                        this.disableConfirmButton = false;  
                    });
                }catch(e){
                    console.error(e);
                    this.showAlert('Attenzione','Errore nella chiamata al server. Non è stato ricevuto un appuntamento valido.','error');
                }
                this.showSpinner = false;
                if (this.searchType.localeCompare('FirstSearch') === 0){
                    this.searchType = 'NewSlot';
                    this.newDateLabel = 'Altre Date';
                    this.refreshRecord = true;
                }
                if (this.searchType.localeCompare('NewSlotModify') === 0){
                    this.searchType = 'NewSlot';
                }
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
        if (this.isCommunity){
            alert(_message);
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: _title,
                    message: _message,
                    variant: _variant
                })
            );
        }  
    }

    async refreshPage(flagCommunity){
        let userCommunity;
        if (!flagCommunity){
            setTimeout(function(){window.location.reload()},3000);
        }else{
            userCommunity = flagCommunity;
            this.dispatchEvent(new CustomEvent('cancelevent',{detail : true}));
        }
    }

    addRecord(element){
        this.records = [...this.records,element];
    }

    formatData(dateToFormat){
        let dataToWork = dateToFormat.split('-');
        return dataToWork[2]+'/'+(dataToWork[1])+'/'+dataToWork[0];
    }

    getDataValueForSearch(appDaConf,slot,requestType){
        if ((requestType === 'NewSlotModify') || (!appDaConf || ! slot)){
            return this.getDefaultSearchValue();
        }else{
            let h = slot.split('/')[0]+':00';
            let dateToWork = new Date(appDaConf+' '+h);
            let milliseconds = dateToWork.getTime();
            if (milliseconds < Date.now()){
                return this.getDefaultSearchValue();
            }else{
                return { data: appDaConf, slot: slot}
            }
        }
    }

    getDefaultSearchValue(){
        const d = new Date();
        let m = d.getMonth() +1; 
        let month = m < 10? '0'+m : m;
        let day = d.getDate() < 10 ? '0'+d.getDate() : d.getDate(); 
        let d1String = d.getFullYear()+'-'+month+'-'+ day;
        let d1 = new Date(d1String);
        let h0 = (d.getHours() === 23)? 0 : d.getHours()+1;
        let h1 = (h0===23)? 0 : h0 + 1;
        if (h0<10){
            h0 = '0'+h0;
        }
        h0 = h0 +':00';
        if (h1<10 ){
            h1 = '0'+h1;
        }
        h1 = h1 +':00';
        return { data: d1, slot: (h0+'/'+h1)};
    }
}