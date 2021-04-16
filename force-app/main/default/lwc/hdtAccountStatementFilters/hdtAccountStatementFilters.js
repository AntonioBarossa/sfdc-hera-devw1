import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const filterObject = {};
const timeLimit = 63072000000;//2years

export default class HdtAccountStatementFilters extends LightningElement {

    @track filterObject = filterObject;
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };
    enableDateControll;
    joinFilterObj = {};

    connectedCallback(){
        this.enableDateControll = true;
        this.joinFilterObj = {
            obj0: {type: 'text', name: 'numeroDocumento', label: 'Nr documento', empty: true, minLength: 2},
            obj1: {type: 'text', name: 'numeroBollettino', label: 'Nr bollettino', empty: true, minLength: 2},
            obj2: {type: 'date', name: 'dataInizio', label: 'Data valuta da', empty: true},
            obj3: {type: 'date', name: 'dataFine', label: 'Data valuta a', empty: true}
    
        };
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

        if(this.enableDateControll){
            this.dateConfiguration();
        }

        console.log('# ' + JSON.stringify(this.filterObject));

        const selectedObj = new CustomEvent("setobjfilter", {
            detail:  {
                requestType: 'filters', filterobj: JSON.stringify(this.filterObject)
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedObj);
        this.closeModal();

    }

    dateConfiguration(){
        //dataInizio valorizzato e dataFine null
        //Se l’operatore inserisce solo la DataInizio, allora DataFine = DataInizio + 2 anni 
        if(!this.joinFilterObj.obj2.empty && this.joinFilterObj.obj3.empty){
            console.log('>>> dataInizio valorizzato e dataFine null');
            var today = new Date(this.filterObject[this.joinFilterObj.obj2.name]);
            var dateArray = this.setDate(today);
            this.filterObject[this.joinFilterObj.obj3.name] = (dateArray[0]+2).toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();
        }

        //dataFine valorizzato e dataInizio null
        //Se l’operatore inserisce solo la DataFine, allora DataInizio = DataFine - 5 anni 
        if(this.joinFilterObj.obj2.empty && !this.joinFilterObj.obj3.empty){
            console.log('dataFine valorizzato e dataInizio null');

            var today = new Date(this.filterObject[this.joinFilterObj.obj3.name]);
            var dateArray = this.setDate(today);
            this.filterObject[this.joinFilterObj.obj2.name] = (dateArray[0]-2).toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();

        }

        //dataFine e dataInizio valorizzati 
        if(!this.joinFilterObj.obj2.empty && !this.joinFilterObj.obj3.empty){
            console.log('dataFine e dataInizio valorizzati');
        }

        //dataFine e dataInizio NON valorizzati
        //use default
        if(this.joinFilterObj.obj2.empty && this.joinFilterObj.obj3.empty){
            console.log('dataFine e dataInizio NON valorizzati');

            var today = new Date();
            var dateArray = this.setDate(today);
            this.filterObject[this.joinFilterObj.obj2.name] = (dateArray[0]-2).toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();
            this.filterObject[this.joinFilterObj.obj3.name] = dateArray[0].toString() + '-' + dateArray[1].toString() + '-' + dateArray[2].toString();

        }
    }

    closeModal(event){
        console.log('# closeModal #');

        //for (var key in this.filterObject) {
        //    delete this.filterObject[key];
        //}

        const closeEvent = new CustomEvent("closemodal", {
            detail:   {booleanVar: 'showFilters'}
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
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
        
        var returnObj = {
            success: false,
            message: ''
        };

        //check if filter obj is empty
        if(Object.keys(this.filterObject).length === 0){
            returnObj.message = 'Bisogna impostare almeno un filtro';
            return returnObj;
        }

        //check if filter attribute obj is empty
        //if(Object.keys(this.filterObject).length < Object.keys(this.joinFilterObj).length){
        //    returnObj.message = 'Manca da valorizzare qualche input';
        //    return returnObj;            
        //}

        var regExp = /[a-zA-Z]/g;

        //numeroBollettino
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.obj0.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.obj0.name])){
                returnObj.message = this.joinFilterObj.obj0.label + ' non può contenere delle lettere';
                return returnObj;
            } else if(this.filterObject[this.joinFilterObj.obj0.name].length < this.filterObject[this.joinFilterObj.obj0.minLength]){
                returnObj.message = this.joinFilterObj.obj0.label + ' almeno ' + this.joinFilterObj.obj0.minLength.toString() + ' caratteri';
                return returnObj;
            }
            this.joinFilterObj.obj0.empty = false;
        } else {
            this.joinFilterObj.obj0.empty = true;
        }

        //numeroFattura
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.obj1.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.obj1.name])){
                returnObj.message = this.joinFilterObj.obj1.label + ' non può contenere delle lettere';
                return returnObj;
            } else if(this.filterObject[this.joinFilterObj.obj1.name].length < this.filterObject[this.joinFilterObj.obj1.minLength]){
                returnObj.message = this.joinFilterObj.obj1.label + ' almeno ' + this.joinFilterObj.obj1.minLength.toString() + ' caratteri';
                return returnObj;
            }
            this.joinFilterObj.obj1.empty = false;
        } else {
            this.joinFilterObj.obj1.empty = true;
        }

        //dataInizio
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.obj2.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.obj2.name])){
                returnObj.message = '"' + this.joinFilterObj.obj2.label + '" ha un formato non corretto';
                return returnObj;
            }
            this.joinFilterObj.obj2.empty = false;
        } else {
            this.joinFilterObj.obj2.empty = true;
        }
        
        //dataFine
        if(this.checkIsNotNull(this.filterObject[this.joinFilterObj.obj3.name])){
            if(regExp.test(this.filterObject[this.joinFilterObj.obj3.name])){
                returnObj.message = '"' + this.joinFilterObj.obj3.label + '" ha un formato non corretto';
                return returnObj;
            }
            this.joinFilterObj.obj3.empty = false;
        } else {
            this.joinFilterObj.obj3.empty = true;
        }
        
        //dataFine e dataInizio valorizzati 
        if(!this.joinFilterObj.obj2.empty && !this.joinFilterObj.obj3.empty){
            //check start/end date
            var start = new Date(this.filterObject[this.joinFilterObj.obj2.name]);
            var end = new Date(this.filterObject[this.joinFilterObj.obj3.name]);

            if(start >= end){
                returnObj.message = 'Data fine inferiore dello start';
                return returnObj;
            }

            var diff = end - start;
            console.log('>>>> ' + start);
            console.log('>>>> ' + end);
            console.log('>>>> ' + diff);

            if(diff > timeLimit){
                returnObj.message = 'Hai selezionato un range maggiore di 2 anni';
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