import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveEligibilityCriteria from '@salesforce/apex/HDT_LC_EligibilityCriteriaController.saveEligibilityCriteria';
import getCityZipCodeObj from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.getCityZipCodeObj';

export default class HdtEligibilityCriteriaConfiguration extends LightningElement {

    @api productid;
    storeData = [];
    @track dataToView = [];
    @track dataRemoved = [];
    showRemovedTable = false;
    buttonLabel = 'uguale a';
    operator = 'equal';
    showEmptyImmage = true;
    showAvailableItems = false;
    showSearchTable = false;
    queryTerm;
    @track provinceOptions;
    currentProvinceId;
    disabled = 'dis';

    @track searchTable = [];
    //enableSearch = false;

    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    connectedCallback(){
        this.getDataFromApex();
        //for(var i=0; i<allData.length; i++){
        //    this.dataToView.push(allData[i]);
        //    this.storeData.push(allData[i]);
        //}
    }

    getDataFromApex(){
        console.log('# get data from apex #');

        getCityZipCodeObj({regionCode: 'EMR'})
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

                this.provinceOptions = result.regionList[0].provinceList;

            } else {
                toastObj.title = 'Attenzione';
                toastObj.message = result.message;
                toastObj.variant = 'warning';
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );

        })
        .catch(error => {
            console.log('# Error -> ' + error.body.message);
        });
    }

    headerCheckbox(event){
        console.log('# headerCheckbox > ');

        this.provinceOptions.forEach(po => {
            po.isEnabled = false;
        }); 


    }

    checkboxHandler(event){
        
        var rowValue = event.currentTarget.dataset.id
        //this.provinceOptions.forEach(po => {
        //    if(po.value===rowValue){
        //        po.isEnabled = event.target.checked;
        //    }
        //});

        let foundRow = this.provinceOptions.find(ele  => ele.value === rowValue);
        foundRow.isEnabled = event.target.checked;

        console.log('# isEnabled > ' + rowValue + ' - ' + foundRow.isEnabled);

        event.cancelBubble = true;
        event.stopPropagation();

    }

    handleRowAction(event) {
        var e = event.currentTarget.dataset.id;
        console.log('# Select row -> ' + e);

        if(!this.showAvailableItems){
            console.log('# enable inpunt search #');
            this.template.querySelectorAll('lightning-input').forEach(li => {
                if(li.name==='enter-search'){
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

        if(this.dataRemoved.length>0){
            this.showRemovedTable = true;
        } else {
            this.showRemovedTable = false;
        }

    }

    /*handleProvinceChange(event) {
        var provId = event.detail.value;
        this.currentProvinceId = provId;
        console.log('# --> provId ' + provId);
        this.dataToView = [];
        this.storeData = [];
        let foundProvince = this.provinceOptions.find(ele  => ele.value === provId);
        //this.storeData = foundProvince.cityAvailable;//+++
        this.dataToView = foundProvince.cityAvailable;
        this.dataRemoved = foundProvince.cityRemoved;
        this.showEmptyImmage = false;
        this.showAvailableItems = true;
        this.showSearchTable = false;
    }*/
    
    changeOperator(event){
        if(event.target.name === 'equal'){
            this.buttonLabel = 'diverso';
            event.target.name = 'notequal';
            this.operator = 'notequal';
        } else {
            this.buttonLabel = 'uguale';
            event.target.name = 'equal';
            this.operator = 'equal';
        }
    }

    handleOnchange(event) {
        console.log('# handleOnchange #');
        console.log('# this.operator > ' + this.operator);

        this.queryTerm = event.target.value;
        console.log('# search -> ' + this.queryTerm);

        this.disabled = 'dis';
        this.showEmptyImmage = false;
        this.showAvailableItems = false;
        this.showSearchTable = true;

        if(this.queryTerm != null && this.queryTerm != '' && this.queryTerm != undefined){
            
            var lowerTerm = this.queryTerm.toLowerCase();
            console.log('# find: ' + lowerTerm );

            this.searchTable = [];
            for(var i=0; i<this.dataToView.length; i++){
                var currentLabel = this.dataToView[i].label.toLowerCase();
                var cap = this.dataToView[i].value;

                if(this.operator === 'equal'){
                    if(currentLabel.startsWith(lowerTerm) || cap.startsWith(this.queryTerm)){
                        this.searchTable.push(this.dataToView[i]);
                    }
                } else {
                    if(!currentLabel.includes(lowerTerm)){
                        this.searchTable.push(this.dataToView[i]);
                    }                    
                }

            }

        } else {
            this.searchTable = [];
            this.disabled = '';
            this.showEmptyImmage = false;
            this.showAvailableItems = true;
            this.showSearchTable = false;

            //for(var i=0; i<this.dataToView.length; i++){
            //    this.searchTable.push(this.dataToView[i]);
            //}
        }
    }

    /*handleOnchange(event) {
        console.log('# handleOnchange #');

        this.queryTerm = event.target.value;
        console.log('# search -> ' + this.queryTerm);

        if(this.queryTerm != null && this.queryTerm != '' && this.queryTerm != undefined){
            
            var lowerTerm = this.queryTerm.toLowerCase();
            console.log('# find: ' + lowerTerm );

            this.dataToView = [];
            for(var i=0; i<this.storeData.length; i++){
                var currentLabel = this.storeData[i].label.toLowerCase();
                var cap = this.storeData[i].value;

                if(currentLabel.startsWith(lowerTerm) || cap.startsWith(this.queryTerm)){
                    this.dataToView.push(this.storeData[i]);
                }
            }

        } else {
            this.dataToView = [];
            for(var i=0; i<this.storeData.length; i++){
                this.dataToView.push(this.storeData[i]);
            }
        }
    }*/

    removeAllItems(event){
        console.log('# removeAllItems #');

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
        //if(!this.showRemovedTable){
        //    this.showRemovedTable = true;
        //}
    }

    restoreItem(event){
        console.log('# restore item #');

        var itemId = event.currentTarget.getAttribute('data-id');
        var itemLabel = event.currentTarget.getAttribute('data-label');
        var itemValue = event.currentTarget.getAttribute('data-value');
        console.log('# To restore ' + itemId + '; ' + itemLabel + '; ' + itemValue);

        var itemRemoved = { label: itemLabel, value: itemValue, id: itemId};

        let element = this.dataRemoved.find(ele  => ele.value === itemId);
        var a = this.dataRemoved.indexOf(element);
        this.dataRemoved.splice(a, 1);

        //check if the item is already stored, todo -> "migliorare"
        let alreadyStored = this.storeData.find(ele  => ele.value === itemValue);
        console.log('@@@ ' + alreadyStored);
        if(alreadyStored == null || alreadyStored == undefined){
            this.storeData.push(itemRemoved);
            this.storeData.sort(this.compare);
        }

        //check if the item is already present, todo -> "migliorare"
        let alreadyPresent = this.dataToView.find(ele  => ele.value === itemId);
        console.log('@@@ ' + alreadyPresent);
        if(alreadyPresent == null || alreadyPresent == undefined){
            this.dataToView.push(itemRemoved);
            this.dataToView.sort(this.compare);
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


    saveAction(){
        console.log('# saveAction #');

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        for(var i=0; i<this.provinceOptions.length; i++){
            this.provinceOptions[i].cityRemoved = [];
        }

        saveEligibilityCriteria({productId: this.productid, dataReceived: JSON.stringify(this.provinceOptions)})
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
            }, 5000);

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
            setTimeout(() => {
                
            }, 1000);
        });
    }

}