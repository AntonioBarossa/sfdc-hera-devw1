import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveEligibilityCriteria from '@salesforce/apex/HDT_LC_EligibilityCriteriaController.saveEligibilityCriteria';
import getCityZipCodeObj from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.getCityZipCodeObj';
import deleteEligibilityCriteria from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.deleteEligibilityCriteria';
import { NavigationMixin } from 'lightning/navigation';
import saveBody from '@salesforce/label/c.HDT_LWC_CriteriaModal_SaveBody';
import saveTitle from '@salesforce/label/c.HDT_LWC_CriteriaModal_SaveTitle';
import closeBody from '@salesforce/label/c.HDT_LWC_CriteriaModal_CloseBody';
import closeTitle from '@salesforce/label/c.HDT_LWC_CriteriaModal_CloseTitle';
import deleteTitle from '@salesforce/label/c.HDT_LWC_CriteriaModal_DeleteTitle';
import deleteBody from '@salesforce/label/c.HDT_LWC_CriteriaModal_DeleteBody';

export default class HdtEligibilityCriteriaConfiguration extends NavigationMixin(LightningElement) {

    label = {
        saveBody,
        saveTitle,
        closeBody,
        closeTitle,
        deleteTitle,
        deleteBody
    };

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
    //cityZipCode.provinceOptions;// --> used with lightning-input
    @track cityZipCode = {};
    //@track cityZipCode.provinceOptions;// --> used with input

    //Boolean to manage show table/image
    showRemovedTable = false;
    showEmptyImmage = true;
    showAvailableItems = false;
    showSearchTable = false;
    showEmptyRemovedImmage = true;
    showSearchRemovedTable = false;
    eligibleForAllCities;
    disableCitySelection = true;
    toggleLabel = 'Valido per tutte le province';
    alreadyLoaded = false;
    editable = false;

    connectedCallback(){
        console.log('>>> eligibilityId > ' + this.eligibilityId);
        this.getDataFromApex();
    }

    controllAllCheckBox(){
        console.log('> controllAllCheckBox');
        var i;
        for (i = 0; i < this.cityZipCode.provinceOptions.length; i++) {
            if(!this.cityZipCode.provinceOptions[i].isEnabled){
                this.setCheckboxHeader(false);
                break;
            }
        }
    }

    setCheckboxHeader(checked){
        this.template.querySelectorAll('lightning-input').forEach(li => {
            if(li.name==='headerCheckbox'){
                li.checked = checked;
            }
        });
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
                this.editable = result.isEditable;
                toastObj.title = 'Successo';
                toastObj.message = result.message;
                toastObj.variant = 'success';
                this.cityZipCode.provinceOptions = [];
                this.cityZipCode.provinceOptions = result.regionList[0].provinceList;
                this.eligibleForAllCities = result.regionList[0].eligibleForAllCities;
                this.controllAllCheckBox();
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

    //handleToggleChange() {
    //    const checked = Array.from(
    //        this.template.querySelectorAll('lightning-input')
    //    )
    //    .filter(element => element.name==='allProvince')
    //    .map(element => element.checked);
    //    this.disableCitySelection = checked[0];

    //    if(this.disableCitySelection){
    //        this.toggleLabel = 'Valido per tutte le province';
    //        this.eligibleForAllCities = true;
    //    } else {
    //        this.toggleLabel = 'Selezione manuale';
    //        this.eligibleForAllCities = false;
    //    }
    //}

    checkboxHeaderHandler(event){
        this.headerHandlerHelper(event.target.checked);
    }

    headerHandlerHelper(headerChecked){
        console.log('# HeaderHandlerHelper ' + headerChecked);
        this.cityZipCode.provinceOptions.forEach(po => {
            po.isEnabled = headerChecked;
        });
        //this.eligibleForAllCities = !this.eligibleForAllCities;
        //console.log('>>> eligibleForAllCities: ' + this.eligibleForAllCities);
    }

    checkboxHandler(event){

        //used with input checkbox
        var rowValue = event.currentTarget.dataset.id

        let foundRow = this.cityZipCode.provinceOptions.find(ele  => ele.value === rowValue);
        foundRow.isEnabled = event.target.checked;

        console.log('# isEnabled > ' + rowValue + ' - ' + foundRow.isEnabled);

        var count = 0;
        this.cityZipCode.provinceOptions.forEach(po => {
            if(po.isEnabled){
                count++;
            }
        });
        
        if(count != this.cityZipCode.provinceOptions.length){
            //this.eligibleForAllCities = false;
            this.setCheckboxHeader(false);
        } else {
            //this.eligibleForAllCities = true;
            this.setCheckboxHeader(true);
        }

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
            //** fix enable search on disabled items*/
            this.template.querySelectorAll('lightning-input').forEach(li => {
                if(li.name==='searchRemoved'){
                    li.disabled = false;
                    this.disabledR = '';
                }
            });
            /**/ 

            let operatorButton = this.template.querySelector('button');
            if(operatorButton.dataset.id==='operator'){
                operatorButton.disabled = false;
            }
        }

        this.cityZipCode.provinceOptions.forEach(li => {
            this.template.querySelector('[data-id="' + li.value + '"]').style.background = '#ffffff';
        });

        //get id row and mark as selected        
        let element = this.template.querySelector('[data-id="' + e + '"]');
        element.style.background = ' #ecebea';

        //get second level list and put in html
        let foundRow = this.cityZipCode.provinceOptions.find(ele  => ele.value === e);
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

        if(this.dataToView.length > 0){
            this.showAvailableItems = true;
            this.showEmptyImmage = false;
        }

        if(this.dataRemoved.length === 0){
            this.showRemovedTable = false;
            this.showEmptyRemovedImmage = true;
        }
        
    }

    restoreAllItem(event){
        console.log('# RESTORE FROM ALL ITEM #');

        if(this.showSearchRemovedTable){
            console.log('# RESTORE FROM SEARCH #');
            this.searchRemovedTable.forEach((i) => {
                let alreadyPresent = this.dataToView.find(ele  => ele.value === i.value);
                if(alreadyPresent == null || alreadyPresent == undefined){
                    var itemRemoved = { label: i.label, value: i.value, id: i.value};
                    this.dataToView.push(itemRemoved);
                }

                let element = this.dataRemoved.find(ele  => ele.value === i.value);
                var a = this.dataRemoved.indexOf(element);
                this.dataRemoved.splice(a, 1);

            });
            this.searchRemovedTable = [];
        } else if(this.showRemovedTable){
            this.dataRemoved.forEach((i) => {
                let alreadyPresent = this.dataToView.find(ele  => ele.value === i.value);
                if(alreadyPresent == null || alreadyPresent == undefined){
                    var itemRemoved = { label: i.label, value: i.value, id: i.value};
                    this.dataToView.push(itemRemoved);
                }
            });
            //this.dataRemoved = [];
            this.dataRemoved.splice(0,this.dataRemoved.length)
            console.log('## ' + this.dataRemoved.length);
        }

        this.dataToView.sort(this.compare);

        if(this.dataToView.length > 0){
            this.showAvailableItems = true;
            this.showEmptyImmage = false;
        }
    
        if(this.dataRemoved.length === 0){
            this.showRemovedTable = false;
            this.showEmptyRemovedImmage = true;
        }

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
        try{
            if(event.detail.decision === 'conf'){
                this[event.detail.operation](event);
            }
            this.modalObj.isVisible = false;
        } catch(e){
            console.error('# Name => ' + e.name );
            console.error('# Message => ' + e.message );
            console.error('# Stack => ' + e.stack );
        }
    }

    saveAction(){
        console.log('# saveAction #');

        if(this.saveActionControll()){
            this.template.querySelector('c-hdt-eligibility-criteria-parameters').handleSubmitButtonClick();
        }
    }

    saveActionControll(){

        var selectedRecord = this.cityZipCode.provinceOptions.filter(function(item) {
            if(item.isEnabled){
                return true;
            } else {
                return false;
            }
        });

        if(selectedRecord.length === 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ATTENZIONE',
                    message: 'Devi selezionare almeno una Provincia/Comune',
                    variant: 'warning',
                    mode: 'sticky'
                }),
            );
            return false;
        } else {
            return true;
        }
    }

    sendToApex(event){
        console.log('# saveAction2 #');

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        var criteriaRecord = event.detail.record;
        console.log('# criteriaRecord > ' + criteriaRecord);

        var n = 0;
        for(var i=0; i<this.cityZipCode.provinceOptions.length; i++){
            if(!this.cityZipCode.provinceOptions[i].isEnabled || this.cityZipCode.provinceOptions[i].cityRemoved.length > 0){
                n++;
            }

            //#### 24-02-2023 enhanced eligibleForAllCities
            //this.cityZipCode.provinceOptions[i].eligibleForAllCities = (this.cityZipCode.provinceOptions[i].cityRemoved.length==0) ? true : false;
            //#### 24-02-2023 enhanced eligibleForAllCities
            this.cityZipCode.provinceOptions[i].cityRemoved = [];
        }

        this.cityZipCode.provinceList = this.cityZipCode.provinceOptions;
        this.cityZipCode.provinceOptions = [];
        //this.cityZipCode.eligibleForAllCities = ((n > 0) ? false : this.eligibleForAllCities);
        this.cityZipCode.eligibleForAllCities = ((n > 0) ? false : true);

        console.log(JSON.stringify(this.cityZipCode));

        //saveEligibilityCriteria({productId: this.productid, record: criteriaRecord, dataReceived: JSON.stringify(this.cityZipCode.provinceOptions)})
        saveEligibilityCriteria({productId: this.productid, record: criteriaRecord, dataReceived: JSON.stringify(this.cityZipCode)})
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
                    this.modalObj.header = this.label.saveTitle;
                    this.modalObj.body = this.label.saveBody;
                    break;
                case 'goBackToRecord':
                    this.modalObj.header = this.label.closeTitle;
                    this.modalObj.body = this.label.closeBody;
                    break;
                case 'delete':
                    this.modalObj.header = this.label.deleteTitle;
                    this.modalObj.body = this.label.deleteBody;

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
        this.cityZipCode.provinceOptions = [];

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