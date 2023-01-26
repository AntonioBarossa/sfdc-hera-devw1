import { LightningElement,track,api,wire } from 'lwc';
import getConfigurationData from '@salesforce/apex/HDT_LC_MeterReadingController.getConfigurationData';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent, FlowAttributeChangeEvent} from 'lightning/flowSupport';
import { getRecord } from 'lightning/uiRecordApi';

export default class HdtMeterReadingDetailTableFlow extends LightningElement {
    
    @api previousButton;
    @api availableActions = [];
    @api cancelCase;
    @api nextLabel;
    @api nextVariant;
    @api readingValue; // UNUSED
    @api totalReadingValue; // UNUSED
    @api selectedReadingValues;
    @api selectedReadingsConcatenated;
    @api selectedReadingDate; //UNUSED
    @api selectedReadingDateString;
    //@frpanico added dispustedReadingVariables
    @api disputedReading; //Gas
    @api disputedReadingOne; //Ele F1
    @api disputedReadingTwo; //Ele F2
    @api disputedReadingThree; //Ele F3

    //buttons
    @api nonStandAlone = false;
    @api maxRows;

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

    @api contractService;



    connectedCallback() {
        this.totalReadingValue = 0;
        console.log('contract number: ' + this.contractNumber);
        this.configurationData();
        //this.template.querySelector('c-hdt-meter-reading-detail-table').loadingData();

        if(this.previousButton && !this.availableActions.find(action => action === 'BACK')){
            this.previousButton = false;
        }
        
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

    handleRowSelection = event =>{
        let readingDate;
        if(event.detail != null){
            console.log('Event' + JSON.stringify(event.detail));
            let selectRow = event.detail;
            console.log('IsArray? >>> ' + Array.isArray(selectRow));
            if(Array.isArray(selectRow) && selectRow.length > 1)
            {
                readingDate = selectRow[0].dataLetturaPianificata;
                //Caso Energia Elettrica
                selectRow.forEach(element => 
                {
                    console.log('Element >>> ' + JSON.stringify(element));
                    if(element.tipoNumeratore === 'Fascia 1')
                    {
                        this.disputedReadingOne = element.posizioniPrecedentiLaVirgola;
                    }
                    else if(element.tipoNumeratore === 'Fascia 2')
                    {
                        this.disputedReadingTwo = element.posizioniPrecedentiLaVirgola;
                    }
                    else
                    {
                        this.disputedReadingThree = element.posizioniPrecedentiLaVirgola;
                    }
                }
                );

            }
            else
            {
                //Caso Gas
                console.log('GAS_CONDITION');
                console.log('VALORE >>> ' + JSON.stringify(selectRow.posizioniPrecedentiLaVirgola));
                readingDate = selectRow.dataLetturaPianificata;
                this.disputedReading = selectRow.posizioniPrecedentiLaVirgola;

            }
            console.log('Data Lettura Contestata >>> ' + readingDate);
            console.log('Lettura Contestata Gas >>> ' + this.disputedReading);
            console.log('Lettura Contestata Ele F1 >>> ' + this.disputedReadingOne);
            console.log('Lettura Contestata Ele F2 >>> ' + this.disputedReadingTwo);
            console.log('Lettura Contestata Ele F3 >>> ' + this.disputedReadingThree);
            //let disputedValue = event.detail.posizioniPrecedentiLaVirgola;
            let dateParse = readingDate.split("/");
            readingDate = dateParse[2] + '-' + dateParse[1] + '-' + dateParse[0];
            //@frpanico added events for "Data Lettura Contestata" and "Valore Lettura Contestata"
            const attributeChangeEvent = new FlowAttributeChangeEvent('selectedReadingDateString', readingDate);
            this.dispatchEvent(attributeChangeEvent);
            const attributeChangeEventDisputed = new FlowAttributeChangeEvent('disputedReading', this.disputedReading);
            this.dispatchEvent(attributeChangeEventDisputed);
            const attributeChangeEventDisputedOne = new FlowAttributeChangeEvent('disputedReadingOne', this.disputedReadingOne);
            this.dispatchEvent(attributeChangeEventDisputedOne);
            const attributeChangeEventDisputedTwo = new FlowAttributeChangeEvent('disputedReadingTwo', this.disputedReadingTwo);
            this.dispatchEvent(attributeChangeEventDisputedTwo);
            const attributeChangeEventDisputedThree = new FlowAttributeChangeEvent('disputedReadingThree', this.disputedReadingThree);
            this.dispatchEvent(attributeChangeEventDisputed);
        }
    }

    handleGoNext() {

        this.cancelCase = false;

        if(this.availableActions.find(action => action === 'NEXT')){

            this.totalReadingValue = this.template.querySelector('c-hdt-meter-reading-detail-table').getSelectedReadingsValue();
            //console.log('selected readings value: ' + this.totalReadingValue);

            const selectedReadingsList = this.template.querySelector('c-hdt-meter-reading-detail-table').getSelectedReadingsList();
            this.selectedReadingValues = JSON.stringify(selectedReadingsList);
            console.log('selected readings list stringified: ' + this.selectedReadingValues);

            this.selectedReadingsConcatenated = this.template.querySelector('c-hdt-meter-reading-detail-table').getSelectedReadingsConcatenated();
            console.log('selected readings concatenated: ' + this.selectedReadingsConcatenated);

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

        if(this.availableActions.find(action => action === 'BACK')){
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }
}