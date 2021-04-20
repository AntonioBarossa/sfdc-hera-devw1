import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveEligibilityCriteria from '@salesforce/apex/HDT_LC_EligibilityCriteriaController.saveEligibilityCriteria';
import getCityZipCodeObj from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.getCityZipCodeObj';
import deleteEligibilityCriteria from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.deleteEligibilityCriteria';
import { NavigationMixin } from 'lightning/navigation';

export default class HdtEligibilityCriteriaConfiguration extends NavigationMixin(LightningElement) {

    @api productid;
    @api eligibilityId;
    showDelete = false;
    buttonLabel = 'uguale a';
    operator = 'equal';
    disabled = 'dis';
    queryTerm;

    buttonLabelR = 'uguale a';
    operatorR = 'equal';
    disabledR = 'dis';
    queryTermR;
    //currentProvinceId;
    
    @track modalObj = {
        isVisible: false,
        header: '',
        body: '',
        operation: ''
    }

    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    //Tables
    @track dataToView = [];
    @track searchTable = [];
    @track dataRemoved = [];
    @track searchRemovedTable = [];
    //provinceOptions;// --> used with lightning-input
    @track provinceOptions;// --> used with input

    //Boolean to manage show table/image
    showRemovedTable = false;
    showEmptyImmage = true;
    showAvailableItems = false;
    showSearchTable = false;
    showEmptyRemovedImmage = true;
    showSearchRemovedTable = false;
    availableForAllCities = true;


    connectedCallback(){
        console.log('>>> eligibilityId > ' + this.eligibilityId);
        this.getDataFromApex();
    }

    renderedCallback(){
        this.handleShowTables();
    }

    handleShowTables(){

    }

    getDataFromApex(){
        console.log('# get data from apex #');

        this.showDelete = (this.eligibilityId != null && this.eligibilityId != '' && this.eligibilityId != undefined) ? true : false;
        console.log('>>> showDelete -> ' + this.showDelete);

        getCityZipCodeObj({regionCode: 'EMR', eligibilityId: this.eligibilityId})
        .then(result => {
            console.log('# getCityZipCodeObj success #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
                this.provinceOptions = [];
                this.provinceOptions = result.regionList[0].provinceList;

            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';
            }

            //this.dispatchEvent(
            //    new ShowToastEvent({
            //        title: toastObj.title,
            //        message: toastObj.message,
            //        variant: toastObj.variant
            //    }),
            //);

        })
        .catch(error => {
            console.log('# Error -> ' + error.body.message);
        });
    }

    checkboxHeaderHandler(event){
        var headerChecked = event.target.checked;
        console.log('# headerCheckbox ' + headerChecked);

        if(headerChecked){
            this.provinceOptions.forEach(po => {
                po.isEnabled = true;
            });
        } else {
            this.provinceOptions.forEach(po => {
                po.isEnabled = false;
            });
        }

        this.availableForAllCities = !this.availableForAllCities;
        console.log('>>> availableForAllCities: ' + this.availableForAllCities);

    }

    checkboxHandler(event){

        //used with input checkbox
        var rowValue = event.currentTarget.dataset.id

        let foundRow = this.provinceOptions.find(ele  => ele.value === rowValue);
        foundRow.isEnabled = event.target.checked;

        console.log('# isEnabled > ' + rowValue + ' - ' + foundRow.isEnabled);

        //event.cancelBubble = true;
        //event.stopPropagation();

    }

    handleRowAction(event) {
        var e = event.currentTarget.dataset.id;
        console.log('# Select row -> ' + e);

        if(!this.showAvailableItems){
            console.log('# enable inpunt search #');
            this.template.querySelectorAll('lightning-input').forEach(li => {
                if(li.name==='searchAvailable'){
                    li.disabled = false;
                    this.disabled = '';
                }
            });

            let operatorButton = this.template.querySelector('button');
            if(operatorButton.dataset.id==='operator'){
                operatorButton.disabled = false;
            }
        }

        this.provinceOptions.forEach(li => {
            this.template.querySelector('[data-id="' + li.value + '"]').style.background = '#ffffff';
        });

        //get id row and mark as selected        
        let element = this.template.querySelector('[data-id="' + e + '"]');
        element.style.background = ' #ecebea';

        //get second level list and put in html
        let foundRow = this.provinceOptions.find(ele  => ele.value === e);
        this.dataToView = foundRow.cityAvailable;
        this.dataRemoved = foundRow.cityRemoved;
        
        this.showEmptyImmage = false;
        this.showAvailableItems = true;
        this.showSearchTable = false;

        this.searchRemovedTable = false;

        if(this.dataRemoved.length>0){
            this.showRemovedTable = true;
            this.showEmptyRemovedImmage = false;
        } else {
            this.showRemovedTable = false;
            this.showEmptyRemovedImmage = true;
        }

    }

    changeOperator(event){
        var operatorType = event.currentTarget.dataset.id;

        console.log('>>> ' + operatorType + ' - ' + event.target.name);

        if(event.target.name === 'equal'){
            if(operatorType==='operatorR'){
                this.buttonLabelR = 'diverso';
                event.target.name = 'notequal';
                this.operatorR = 'notequal';
            } else if(operatorType==='operator'){
                this.buttonLabel = 'diverso';
                event.target.name = 'notequal';
                this.operator = 'notequal';
            }
        } else {
            if(operatorType==='operatorR'){
                this.buttonLabelR = 'uguale';
                event.target.name = 'equal';
                this.operatorR = 'equal';
            } else if(operatorType==='operator'){            
                this.buttonLabel = 'uguale';
                event.target.name = 'equal';
                this.operator = 'equal';
            }
        }
    }

    handleSearch(event) {
        console.log('# handleSearch #');

        var searchType = event.target.name;
        console.log('# searchType >> ' + searchType);

        var currentOperator = '';
        var resultTable = '';
        var searchFrom = '';

        switch (searchType) {
            case 'searchAvailable':
                currentOperator = this.operator;
                resultTable = 'searchTable';
                searchFrom = 'dataToView';
                this.disabled = 'dis';
                this.showEmptyImmage = false;
                this.showAvailableItems = false;
                this.showSearchTable = true;
                break;
            case 'searchRemoved':
                currentOperator = this.operatorR;
                resultTable = 'searchRemovedTable';
                searchFrom = 'dataRemoved';
                this.showRemovedTable = false;
                this.showEmptyRemovedImmage = false;
                this.showSearchRemovedTable = true;
        }

        console.log('# this.operator > ' + currentOperator);

        this.queryTerm = event.target.value;
        console.log('# search -> ' + this.queryTerm);

        
        if(this.queryTerm != null && this.queryTerm != '' && this.queryTerm != undefined){
            
            var lowerTerm = this.queryTerm.toLowerCase();
            console.log('# find: ' + lowerTerm );

            this[resultTable] = [];
            for(var i=0; i<this[searchFrom].length; i++){
                var currentLabel = this[searchFrom][i].label.toLowerCase();
                var cap = this[searchFrom][i].value;

                if(currentOperator === 'equal'){
                    if(currentLabel.startsWith(lowerTerm) || cap.startsWith(this.queryTerm)){
                        this[resultTable].push(this[searchFrom][i]);
                    }
                } else {
                    if(!currentLabel.includes(lowerTerm)){
                        this[resultTable].push(this[searchFrom][i]);
                    }                    
                }

            }

        } else {
            this[resultTable] = [];

            switch (searchType) {
                case 'searchAvailable':
                    this.disabled = '';
                    this.showEmptyImmage = false;
                    this.showAvailableItems = true;
                    this.showSearchTable = false;
                    break;
                case 'searchRemoved':
                    this.showEmptyRemovedImmage = false;
                    this.showRemovedTable = true;
                    this.showSearchRemovedTable = false;
            }

        }
    }

    removeAllItems(event){
        console.log('# removeAllItems #');

        //Remove from search table
        if(this.showSearchTable){
            console.log('# Remove from SearchTable');
            this.searchTable.forEach((i) => {
                //find and remove item from filtered list
                let element = this.dataToView.find(ele  => ele.value === i.value);
                var index = this.dataToView.indexOf(element);
                this.dataToView.splice(index, 1);
    
                var itemRemoved = { label: i.label, value: i.value, id: i.id};
                this.dataRemoved.push(itemRemoved);
            });
    
            this.showAvailableItems = true;
            this.showSearchTable = false;
            this.showRemovedTable = true;
            this.showEmptyRemovedImmage = false;
        } else if(this.showAvailableItems){
            console.log('# Remove from AvailableItems');
            this.dataToView.forEach((i) => {    
                var itemRemoved = { label: i.label, value: i.value, id: i.id};
                this.dataRemoved.push(itemRemoved);
            });
            this.dataToView.splice(0, this.dataToView.length);
            this.showAvailableItems = false;
            this.showSearchTable = false;
            this.showRemovedTable = true;
            this.showEmptyImmage = true;
        }

        if(this.dataRemoved.length>0){
            this.showRemovedTable = true;
            this.showEmptyRemovedImmage = false;
            this.template.querySelectorAll('lightning-input').forEach(li => {
                if(li.name==='searchRemoved'){
                    li.disabled = false;
                    this.disabledR = '';
                }
            });
        }


    }

    removeItem(event){
        console.log('# removeItem #');

        var itemId = event.currentTarget.getAttribute('data-id');
        var itemLabel = event.currentTarget.getAttribute('data-label');
        var itemValue = event.currentTarget.getAttribute('data-value');
        console.log('# Remove ' + itemId + '; ' + itemLabel + '; ' + itemValue);

        var tableType = event.target.name;
        console.log('# tableType > ' + tableType);

        if(tableType != null && tableType != '' && tableType != undefined && tableType === 'searchTable'){
            let element = this.searchTable.find(ele  => ele.value === itemId);
            var index = this.searchTable.indexOf(element);
            this.searchTable.splice(index, 1);           
        }

        //find and remove item from filtered list
        let element = this.dataToView.find(ele  => ele.value === itemId);
        var index = this.dataToView.indexOf(element);
        this.dataToView.splice(index, 1);

        var itemRemoved = { label: itemLabel, value: itemValue, id: itemId};
        this.dataRemoved.push(itemRemoved);
        this.showRemovedTable = true;

        if(this.dataRemoved.length>0){
            this.showRemovedTable = true;
            this.showEmptyRemovedImmage = false;
            this.template.querySelectorAll('lightning-input').forEach(li => {
                if(li.name==='searchRemoved'){
                    li.disabled = false;
                    this.disabledR = '';
                }
            });
        }

    }

    restoreItem(event){
        console.log('# restore item #');

        var itemId = event.currentTarget.getAttribute('data-id');
        var itemLabel = event.currentTarget.getAttribute('data-label');
        var itemValue = event.currentTarget.getAttribute('data-value');
        console.log('# To restore >> ' + itemId + '; ' + itemLabel + '; ' + itemValue);

        var itemRemoved = { label: itemLabel, value: itemValue, id: itemId};

        let element = this.dataRemoved.find(ele  => ele.value === itemId);
        var a = this.dataRemoved.indexOf(element);
        this.dataRemoved.splice(a, 1);

        var tableType = event.target.name;
        console.log('# tableType > ' + tableType);

        if(tableType != null && tableType != '' && tableType != undefined && tableType === 'searchRemovedTable'){
            let element = this.searchRemovedTable.find(ele  => ele.value === itemId);
            var a = this.searchRemovedTable.indexOf(element);
            this.searchRemovedTable.splice(a, 1);
        }

        //check if the item is already present, todo -> "migliorare"
        let alreadyPresent = this.dataToView.find(ele  => ele.value === itemId);
        console.log('@@@ ' + alreadyPresent);
        if(alreadyPresent == null || alreadyPresent == undefined){
            this.dataToView.push(itemRemoved);
            this.dataToView.sort(this.compare);
        }

        if(this.dataToView.length>0){
            this.showAvailableItems = true;
            this.showEmptyImmage = false;
        }

        if(this.dataRemoved.length===0){
            this.showRemovedTable = false;
        }
        
    }

    restoreAllItem(event){
        console.log('# restoreAllItem #');
    }

    compare(a, b) {
        const labelA = a.label.toUpperCase();
        const labelB = b.label.toUpperCase();

        let comparison = 0;
        if (labelA > labelB) {
            comparison = 1;
        } else if (labelA < labelB) {
            comparison = -1;
        }
        return comparison;
    }

    modalResponse(event){
        if(event.detail.decision === 'conf'){
            this[event.detail.operation](event);
        }
        this.modalObj.isVisible = false;
    }

    saveAction(){
        console.log('# saveAction #');
        this.template.querySelector('c-hdt-eligibility-criteria-parameters').handleSubmitButtonClick();
    }

    sendToApex(event){
        console.log('# saveAction2 #');

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        var criteriaRecord = event.detail.record;
        console.log('# criteriaRecord > ' + criteriaRecord);

        for(var i=0; i<this.provinceOptions.length; i++){
            this.provinceOptions[i].cityRemoved = [];
        }

        saveEligibilityCriteria({productId: this.productid, record: criteriaRecord, dataReceived: JSON.stringify(this.provinceOptions)})
        .then(result => {
            console.log('# save success #');
            console.log('# resp -> ' + result.success);

            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };

            if(result.success){
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';                    
            }

            this.error = undefined;

            setTimeout(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: toastObj.title,
                        message: toastObj.message,
                        variant: toastObj.variant
                    }),
                );
                this.spinnerObj.spinner = false;
                this.goBackToRecord();
            }, 2000);

        })
        .catch(error => {
            console.log('# save error #');
            console.log('# resp -> ' + result.message);

            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while saving Record',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    openConfirmation(event){
        try {
            switch (event.target.name) {
                case 'saveAction':
                    this.modalObj.header = 'Salva il criterio';
                    this.modalObj.body = 'Questa configurazione verrà salvata su Salesforce. Vuoi confermare?';
                    break;
                case 'goBackToRecord':
                    this.modalObj.header = 'Chiudi la configurazione';
                    this.modalObj.body = 'Perderai tutte le tue configurazioni, vuoi procedere?';
                    break;
                case 'delete':
                    this.modalObj.header = 'Elimina il criterio';
                    this.modalObj.body = 'Perderai tutte le tue configurazioni, vuoi procedere?';

            }

            this.modalObj.isVisible = true;
            this.modalObj.operation = event.target.name;

        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    goBackToRecord(){
        console.log('# goBackToRecord -> ' + this.productid);

        this.dataToView = [];
        this.searchTable = [];
        this.dataRemoved = [];
        this.searchRemovedTable = [];
        this.provinceOptions = [];

        const goback = new CustomEvent("goback", {
            detail: {prodId: this.productid}
        });

        // Dispatches the event.
        this.dispatchEvent(goback);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.productid,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });

    }

    delete(){
        console.log('# delete #');

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'deletingdata slds-text-heading_small';

        var toastObj = {success: true, title: '', message: '', variant: ''};

        deleteEligibilityCriteria({productId: this.productid, eligibilityId: this.eligibilityId})
        .then(result => {
            console.log('# delete success #');
            console.log('# resp -> ' + result.success);

            if(result.success){
                toastObj.success = true;
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';

                this.goBackToRecord();

            } else {
                toastObj.success = false;
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';
                
                //this.errorObj.showError = true;
                //this.errorObj.errorString = result.message;

            }
            
            this.spinnerObj.spinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant,
                })
            );

        })
        .catch(error => {
            //this.errorObj.showError = true;
            //this.errorObj.errorString = error.body.message;
            this.spinnerObj.spinner = false;

            toastObj.success = false;
            toastObj.title = 'Attenzione';
            toastObj.message = error.body.message;
            toastObj.variant = 'warning';

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant,
                })
            );
        });

    }

}