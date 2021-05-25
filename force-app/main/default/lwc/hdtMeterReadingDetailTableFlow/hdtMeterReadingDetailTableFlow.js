import { LightningElement,track,api } from 'lwc';
import getConfigurationData from '@salesforce/apex/HDT_LC_MeterReadingController.getConfigurationData';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

export default class HdtMeterReadingDetailTableFlow extends LightningElement {

    @api availableActions = [];
    @api cancelCase;
    @api nextLabel;
    @api nextVariant;
    @api readingValue; // UNUSED
    @api totalReadingValue; // UNUSED
    @api selectedReadingValues;

    @api contractNumber;
    @track meterReadingColumns;
    loadData = false;
    spinner = true;

    @api
    get variantButton(){
        if(this.nextVariant != null && this.nextVariant !="" && this.nextVariant != "undefined")
            return this.nextVariant;
        else 
            return "brand"
    }

    @api
    get labelButton(){
        if(this.nextLabel != null && this.nextLabel!="" && this.nextLabel != "undefined")
            return this.nextLabel;
        else 
            return "Conferma Pratica"
    }



    connectedCallback() {
        this.totalReadingValue = 0;
        console.log('contract number: ' + this.contractNumber);
        this.configurationData();
        //this.template.querySelector('c-hdt-meter-reading-detail-table').loadingData();
    }

    configurationData(){
        getConfigurationData().then(result => {

            if(result.success){
                this.meterReadingColumns = JSON.parse(result.meterReadingTable);
                console.log('HdtMeterReadingDetailTableFlow columns: ' + JSON.stringify(this.meterReadingColumns));
            } else {
                console.log('>>>> ERROR > configurationData');
                this.spinner = false;                
            }

        }).catch(error => {
            console.log('>>>> ERROR - catch');
            console.log(JSON.stringify(error));
        });
    }


    dataload(event){
        this.spinner = event.detail.spinner;
    }


    handleGoNext() {

        this.cancelCase = false;

        if(this.availableActions.find(action => action === 'NEXT')){

            this.totalReadingValue = this.template.querySelector('c-hdt-meter-reading-detail-table').getSelectedReadingsValue();
            console.log('selected readings value: ' + this.totalReadingValue);

            const selectedReadingsList = this.template.querySelector('c-hdt-meter-reading-detail-table').getSelectedReadingsList();
            this.selectedReadingValues = JSON.stringify(selectedReadingsList);
            console.log('selected readings list stringified: ' + this.selectedReadingValues);

            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);

        } else {
            const navigateFinish = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinish);
        }

    }

    handleCancel(){

        if(this.availableActions.find(action => action === 'NEXT')){

            this.cancelCase = true;

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    handleGoBack(){

        const navigateBackEvent = new FlowNavigationBackEvent();

        this.dispatchEvent(navigateBackEvent);

    }
}