import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const filterObject = {};

export default class HdtAccountStatementFilters extends LightningElement {

    @api filterType;
    @track filterObject = filterObject;
    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };
    enableDateControll;
    joinFilterObj = {};

    @track billingItem = {
        selectedId: '',
        name: '',
        code: ''
    };

    @track contractItem = {
        selectedId: '',
        name: '',
        code: ''
    }

    serviceValues = [];
    stepValues = [];

    connectedCallback(){
        console.log('>>> filterType ' + this.filterType);
        this.enableDateControll = true;
        this.joinFilterObj = {
            obj1: {enable: false, name: 'contratto', label: 'Contratto', empty: true},
            obj2: {enable: false, name: 'contoContrattuale', label: 'Conto Contrattuale', empty: true},
            obj3: {enable: false, name: 'numeroFattura', label: 'Nr. Fattura', empty: true},
            obj4: {enable: false, name: 'servizio', label: 'Servizio', empty: true},
            obj5: {enable: false, name: 'stepSollecito', label: 'Step di sollecito', empty: true}
        };

        switch (this.filterType) {
            case 'contractService':
                    this.joinFilterObj.obj1.enable = true;
                    this.joinFilterObj.obj4.enable = true;
                break;
            case 'paperlessFilters':
                this.joinFilterObj.obj1.enable = true;
                this.joinFilterObj.obj2.enable = true;
                this.joinFilterObj.obj3.enable = true;
                this.joinFilterObj.obj4.enable = true;
                this.joinFilterObj.obj5.enable = true;
                break;
            case 'lwcmethod':
                //
        }

        this.serviceValues = [{label: 'Energia elettrica', value: '13'}, {label: 'Gas', value: '10'}];
        this.stepValues = [{label: 'Step1', value: 'Step1'}, {label: 'Step2', value: 'Step2'}];
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

       //var respCheck = this.checkValue();

       //console.log('#### ' + respCheck.success);

       //if(!respCheck.success){
       //    this.dispatchEvent(
       //        new ShowToastEvent({
       //            title: 'Attenzione',
       //            message: respCheck.message,
       //            variant: 'warning'
       //        })
       //    );
       //    return;
       //}

        console.log('# ' + JSON.stringify(this.filterObject));

        const selectedObj = new CustomEvent("setobjfilter", {
            detail:  {
                requestType: this.filterType, filterobj: JSON.stringify(this.filterObject)
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedObj);
        this.closeModal();

    }

    handleContractSelection(event){
        console.log('# from lookup: ' + event.detail.selectedId + ' - ' + event.detail.name + ' - ' + event.detail.code);
        this.contractItem = {
            selectedId: event.detail.selectedId,
            name: event.detail.name,
            code: event.detail.code
        }

        this.filterObject['contratto'] = event.detail.name;
    }

    handleBillingSelection(event){
        console.log('# from lookup: ' + event.detail.selectedId + ' - ' + event.detail.name + ' - ' + event.detail.code);
        this.billingItem = {
            selectedId: event.detail.selectedId,
            name: event.detail.name,
            code: event.detail.code
        }

        this.filterObject['contoContrattuale'] = event.detail.name;
    }

    closeModal(event){
        console.log('# closeModal #');

        //for (var key in this.filterObject) {
        //    delete this.filterObject[key];
        //}

        const closeEvent = new CustomEvent("closemodal", {
            detail:  {booleanVar: 'showFilters2'}
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
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