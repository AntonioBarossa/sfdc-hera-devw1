import { LightningElement, track } from 'lwc';
import getFieldValues from '@salesforce/apex/HDT_LC_AccountStatementController.getFieldValues';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const filterObject = {};

export default class HdtJoinFilterModal extends LightningElement {

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

    @track joinFilterObj = {
        obj0: {label: 'Livello di aggregazione', name: 'aggregazione'},
        obj1: {label: 'Numero fattura', name: 'numeroFattura', minLength: 12},
        obj2: {label: 'Conto contrattuale', name: 'contoContrattuale'},
        obj3: {label: 'Numero bollettino', name: 'numeroBollettino', minLength: 16},
        obj4: {label: 'Data emissione da', name: 'dataInizio'},
        obj5: {label: 'Data emissione a', name: 'dataFine'},
        obj6: {label: 'Società', name: 'societa'}
    };


    connectedCallback(){
        this.spinnerObj.spinner = true;
        this.getFieldValues();
    }

    getFieldValues(){
        console.log('# getFieldValues #');
        getFieldValues()
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
            detail:  {action: ''}
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

        this.filterObject['contoContrattuale'] = event.detail.selectedId;
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

        const selectedObj = new CustomEvent("setobjfilter", {
            detail:  {
                filterobj: JSON.stringify(this.filterObject)
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedObj);
        this.closeModal();
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

        if(Object.keys(this.filterObject).length < Object.keys(this.joinFilterObj).length){
            returnObj.message = 'Manca da valorizzare qualche input';
            return returnObj;            
        }

        //check all fields
        //aggregazione no check needed
        //contoContrattuale no check needed
        //societa no check needed

        var regExp = /[a-zA-Z]/g;
        
        //numeroFattura
        if(regExp.test(this.filterObject[this.joinFilterObj.obj1.name])){
            returnObj.message = this.joinFilterObj.obj1.label + ' non può contenere delle lettere';
            return returnObj;
        } else if(this.filterObject[this.joinFilterObj.obj1.name].length < this.filterObject[this.joinFilterObj.obj1.minLength]){
            returnObj.message = this.joinFilterObj.obj1.label + ' almeno 12 caratteri';
            return returnObj;
        }

        //numeroBollettino
        if(regExp.test(this.filterObject[this.joinFilterObj.obj3.name])){
            returnObj.message = this.joinFilterObj.obj3.label + ' non può contenere delle lettere';
            return returnObj;
        } else if(this.filterObject[this.joinFilterObj.obj3.name].length < this.filterObject[this.joinFilterObj.obj3.minLength]){
            returnObj.message = this.joinFilterObj.obj3.label + ' almeno 12 caratteri';
            return returnObj;
        }

        //dataInizio
        if(regExp.test(this.filterObject[this.joinFilterObj.obj4.name])){
            returnObj.message = '"' + this.joinFilterObj.obj4.label + '" ha un formato non corretto';
            return returnObj;
        }
        
        //dataFine
        if(regExp.test(this.filterObject[this.joinFilterObj.obj5.name])){
            returnObj.message = '"' + this.joinFilterObj.obj5.label + '" ha un formato non corretto';
            return returnObj;
        }
        
        //check start/end date
        var start = new Date(this.filterObject[this.joinFilterObj.obj4.name]);
        var end = new Date(this.filterObject[this.joinFilterObj.obj5.name]);

        if(start >= end){
            returnObj.message = 'Data fine inferiore dello start';
            return returnObj;
        }

        returnObj.success = true;
        return returnObj;
    }

}