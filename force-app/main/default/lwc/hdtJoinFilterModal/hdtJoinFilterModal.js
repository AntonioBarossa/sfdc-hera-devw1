import { LightningElement, track, api } from 'lwc';
import getFieldValues from '@salesforce/apex/HDT_LC_AccountStatementController.getFieldValues';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const filterObject = {};
const timeLimit = 157680000000;//5years

export default class HdtJoinFilterModal extends LightningElement {

    @api tabCode;
    @track filterObject = filterObject;
    @track item = {
        selectedId: '',
        name: '',
        code: ''
    }
    companyValues = [];
    picklistValues = [];
    showPick = false;

    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    joinFilterObj = {
        aggregazione: {showField: true, label: 'Livello di aggregazione', name: 'aggregazione', empty: true},
        numeroFattura: {showField: true, label: 'Numero fattura', name: 'numeroFattura', minLength: 12, empty: true},
        contoContrattuale: {showField: true, label: 'Conto contrattuale', name: 'contoContrattuale', empty: true},
        numeroBollettino: {showField: true, label: 'Numero bollettino', name: 'numeroBollettino', minLength: 16, empty: true},
        dataInizio: {showField: true, label: 'Data emissione da', name: 'dataInizio', empty: true},
        dataFine: {showField: true, label: 'Data emissione a', name: 'dataFine', empty: true},
        societa: {showField: true, label: 'Società', name: 'societa', empty: true},
        numeroDocumento: {showField: true, label: 'N. piano rata', name: 'numeroDocumento', minLength: 12, empty: true}
    };


    connectedCallback(){
        
        console.log('>>>>>> join filter modal > ' + this.tabCode);

        switch (this.tabCode) {
            case 'EC':
                this.joinFilterObj.numeroDocumento.showField = false;
                break;
            case 'EC1':
                this.joinFilterObj.numeroFattura.showField = false;
                this.joinFilterObj.numeroBollettino.showField = false;
                this.joinFilterObj.societa.showField = false;
                this.joinFilterObj.numeroDocumento.showField = false;
                break;
            case 'EC4':
                this.joinFilterObj.numeroFattura.showField = false;
                this.joinFilterObj.numeroBollettino.showField = false;
                this.joinFilterObj.societa.showField = false;
        }

        this.spinnerObj.spinner = true;
        this.getFieldValues();
    }

    getFieldValues(){
        console.log('# getFieldValues #');
        getFieldValues({tabCode: this.tabCode})
        .then(result => {
            
            if(result.success){
               
               result.companyList.forEach(li => {
                   this.companyValues.push({label: li.label, value: li.value});
               });
               
               result.joinLevelList.forEach(li => {
                    this.picklistValues.push({label: li.label, value: li.value});
               });
               
                this.showPick = true;
                this.spinnerObj.spinner = false;
            } else {
                this.closeModal();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione: Problema nel recupero dei valori picklist',
                        message: result.message,
                        variant: 'warning'
                    })
                );
            }
        })
        .catch(error => {
            console.log('# Error: ' + error);
        });

    }

    closeModal() {
        console.log('# closeModal #');

        for (var key in this.filterObject) {
            delete this.filterObject[key];
        }

        const closeModal = new CustomEvent("closemodal", {
            detail:  {booleanVar: 'joinFilterModal'}
        });
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }

    handleSelection(event){
        console.log('# from lookup: ' + event.detail.selectedId + ' - ' + event.detail.name + ' - ' + event.detail.code);
        this.item = {
            selectedId: event.detail.selectedId,
            name: event.detail.name,
            code: event.detail.code
        }

        this.filterObject['contoContrattuale'] = event.detail.name;
    }

    setFilterParam(event){
        var fieldId = event.currentTarget.dataset.id;
        var value;

        if(event.currentTarget.dataset.type == 'checkbox'){
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            )
            .filter(element => element.checked)
            .map(element => element.name);
    
            value = (checked.filter(c => { return c ==  fieldId})[0] != undefined) ? true : false;

        } else {
            value = event.target.value;
        }

        console.log('# field -> ' + fieldId + ' - value -> ' + value);
        this.filterObject[fieldId] = value;
    }

    applyFilter(){
        console.log('# applyFilter #');

        var respCheck = this.checkValue();
        console.log('#### ' + respCheck.success);

        if(!respCheck.success){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: respCheck.message,
                    variant: 'warning'
                })
            );
            return;
        }

        //dataInizio valorizzato e dataFine null
        //Se l’operatore inserisce solo la DataInizio, allora DataFine = DataInizio + 5 anni 
        if(!this.joinFilterObj.dataInizio.empty && this.joinFilterObj.dataFine.empty){
            console.log('>>> dataInizio valorizzato e dataFine null');
            var today = new Date(this.filterObject[this.joinFilterObj.dataInizio.name]);
            var dateArray = this.setDate(today);
            this.filterObject[this.joinFilterObj.dataFine.name] = (dateArray[0]+5).toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();
        }

        //dataFine valorizzato e dataInizio null
        //Se l’operatore inserisce solo la DataFine, allora DataInizio = DataFine - 5 anni 
        if(this.joinFilterObj.dataInizio.empty && !this.joinFilterObj.dataFine.empty){
            console.log('dataFine valorizzato e dataInizio null');

            var today = new Date(this.filterObject[this.joinFilterObj.dataFine.name]);
            var dateArray = this.setDate(today);
            this.filterObject[this.joinFilterObj.dataInizio.name] = (dateArray[0]-5).toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();

        }

        //dataFine e dataInizio valorizzati 
        if(!this.joinFilterObj.dataInizio.empty && !this.joinFilterObj.dataFine.empty){
            console.log('dataFine e dataInizio valorizzati');
        }

        //dataFine e dataInizio NON valorizzati
        //use default
        if(this.joinFilterObj.dataInizio.empty && this.joinFilterObj.dataFine.empty){
            console.log('dataFine e dataInizio NON valorizzati');

            var today = new Date();
            var dateArray = this.setDate(today);
            this.filterObject[this.joinFilterObj.dataInizio.name] = (dateArray[0]-5).toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();
            this.filterObject[this.joinFilterObj.dataFine.name] = dateArray[0].toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();

        }

        const selectedObj = new CustomEvent("setobjfilter", {
            detail:  {
                requestType: 'joinFilter', filterobj: JSON.stringify(this.filterObject)
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedObj);
        this.closeModal();
    }

    setDate(currentDate){
        var year = currentDate.getFullYear();
        var currentMonth = currentDate.getMonth() + 1;
        var month = ((currentMonth<10) ? '0' + currentMonth.toString() : currentMonth.toString());
        var day = ((currentDate.getDate()<10) ? '0' + currentDate.getDate().toString() : currentDate.getDate().toString());
        return [year, month, day];
    }

    checkValue(){
        console.log('# check value #');
        console.log('# ' + JSON.stringify(this.filterObject));

        var returnObj = {
            success: false,
            message: ''
        };

        //check if filter obj is empty
        if(Object.keys(this.filterObject).length === 0){
            returnObj.message = 'Nessun input';
            return returnObj;
        }

        //check if filter attribute obj is empty
        //if(Object.keys(this.filterObject).length < Object.keys(this.joinFilterObj).length){
        //    returnObj.message = 'Manca da valorizzare qualche input';
        //    return returnObj;            
        //}

        //aggregazione
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.aggregazione.name])){
            this.joinFilterObj.aggregazione.empty = false;
        } else {
            this.joinFilterObj.aggregazione.empty = true;
        }

        var regExp = /[a-zA-Z]/g;
        
        //numeroFattura
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.numeroFattura.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.numeroFattura.name])){
                returnObj.message = this.joinFilterObj.numeroFattura.label + ' non può contenere delle lettere';
                return returnObj;
            } else if(this.filterObject[this.joinFilterObj.numeroFattura.name].length < this.filterObject[this.joinFilterObj.numeroFattura.minLength]){
                returnObj.message = this.joinFilterObj.numeroFattura.label + ' almeno 12 caratteri';
                return returnObj;
            }
            this.joinFilterObj.numeroFattura.empty = false;
        } else {
            this.joinFilterObj.numeroFattura.empty = true;
        }

        //contoContrattuale
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.contoContrattuale.name])){
            this.joinFilterObj.contoContrattuale.empty = false;
        } else {
            this.joinFilterObj.contoContrattuale.empty = true;
        }

        //numeroBollettino
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.numeroBollettino.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.numeroBollettino.name])){
                returnObj.message = this.joinFilterObj.numeroBollettino.label + ' non può contenere delle lettere';
                return returnObj;
            } else if(this.filterObject[this.joinFilterObj.numeroBollettino.name].length < this.filterObject[this.joinFilterObj.numeroBollettino.minLength]){
                returnObj.message = this.joinFilterObj.numeroBollettino.label + ' almeno 12 caratteri';
                return returnObj;
            }
            this.joinFilterObj.numeroBollettino.empty = false;
        } else {
            this.joinFilterObj.numeroBollettino.empty = true;
        }

        //societa
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.societa.name])){
            this.joinFilterObj.societa.empty = false;
        } else {
            this.joinFilterObj.societa.empty = true;
        }

        //dataInizio
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.dataInizio.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.dataInizio.name])){
                returnObj.message = '"' + this.joinFilterObj.dataInizio.label + '" ha un formato non corretto';
                return returnObj;
            }
            this.joinFilterObj.dataInizio.empty = false;
        } else {
            this.joinFilterObj.dataInizio.empty = true;
        }
        
        //dataFine
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.dataFine.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.dataFine.name])){
                returnObj.message = '"' + this.joinFilterObj.dataFine.label + '" ha un formato non corretto';
                return returnObj;
            }
            this.joinFilterObj.dataFine.empty = false;
        } else {
            this.joinFilterObj.dataFine.empty = true;
        }
        
        //dataFine e dataInizio valorizzati 
        if(!this.joinFilterObj.dataInizio.empty && !this.joinFilterObj.dataFine.empty){
            //check start/end date
            var start = new Date(this.filterObject[this.joinFilterObj.dataInizio.name]);
            var end = new Date(this.filterObject[this.joinFilterObj.dataFine.name]);

            if(start >= end){
                returnObj.message = 'Data fine inferiore dello start';
                return returnObj;
            }

            var diff = end - start;
            console.log('>>>> ' + start);
            console.log('>>>> ' + end);
            console.log('>>>> ' + diff);

            if(diff > timeLimit){
                returnObj.message = 'Hai selezionato un range maggiore di 5 anni';
                return returnObj;    
            }

        }

        returnObj.success = true;
        return returnObj;
    }

    checkIsNotNull(valueToCheck){
        if(valueToCheck !== undefined && valueToCheck !== '' && valueToCheck !== null){
            return true;
        } else {
            return false;
        }        
    }

}