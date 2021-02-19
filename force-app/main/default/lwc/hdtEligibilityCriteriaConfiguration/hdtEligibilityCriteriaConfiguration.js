import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveCityEligibility from '@salesforce/apex/HDT_LC_EligibilityCriteriaController.saveCityEligibility';
import getTreeObj from  '@salesforce/apex/HDT_LC_EligibilityCriteriaController.getTreeObj';

const dataRemoved = [];

export default class HdtEligibilityCriteriaConfiguration extends LightningElement {

    @api productid;
    storeData = [];
    @track dataToView = [];
    @track dataRemoved = dataRemoved;
    showTable = false;
    showAvailableItems = false;
    queryTerm;
    provinceOptions;

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

        getTreeObj({regionCode: 'EMR'})
        .then(result => {
            console.log('# getTreeObj success #');
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

    handleProvinceChange(event) {
        var provId = event.detail.value;
        console.log('# --> provId ' + provId);
        this.dataToView = [];
        this.storeData = [];
        let foundProvince = this.provinceOptions.find(ele  => ele.value === provId);
        this.dataToView = foundProvince.cityList;
        this.storeData = foundProvince.cityList;
        this.showAvailableItems = true;
    }

    handleOnchange(event) {
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
    }

    searchField(event) {
        console.log('# searchField #');
    }

    searchCity(event){
        console.log('# searchCity #');
    }

    removeItem(event){
        console.log('# removeItem #');

        var itemId = event.currentTarget.getAttribute('data-id');
        var itemLabel = event.currentTarget.getAttribute('data-label');
        var itemValue = event.currentTarget.getAttribute('data-value');
        console.log('# Remove ' + itemId + '; ' + itemLabel + '; ' + itemValue);

        //find and remove item from filtered list
        let element = this.dataToView.find(ele  => ele.value === itemId);
        var index = this.dataToView.indexOf(element);
        this.dataToView.splice(index, 1);

        //find and remove item from stored list
        let storedEle = this.storeData.find(ele  => ele.value === itemId);
        var storedIdex = this.storeData.indexOf(storedEle);
        this.storeData.splice(storedIdex, 1);

        //insert item removed to removed items list
        var itemRemoved = { label: itemLabel, value: itemValue, id: itemId};
        this.dataRemoved.push(itemRemoved);

        if(!this.showTable){
            this.showTable = true;
        }
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
        let alreadyStored = this.storeData.find(ele  => ele.label === itemId);
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
        console.log('# cityLenght -> ' + this.storeData.length);

        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';

        /*for(var i=0; i<this.storeData.length; i++){
            console.log('# ' + this.storeData[i].label + ' - ' + this.storeData[i].value);
        }*/

        saveCityEligibility({productId: this.productid, dataReceived: JSON.stringify(this.storeData)})
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