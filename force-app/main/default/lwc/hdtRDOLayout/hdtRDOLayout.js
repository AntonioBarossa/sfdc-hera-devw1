import { LightningElement, track, wire, api } from 'lwc';
import getRecord from '@salesforce/apex/HDT_LC_RDOLayout.getRecord';
export default class HdtRDOLayout extends LightningElement {
    parameters = {};
    recordId;
    activeSectionsMessage = '';
    parameters = {};      
    @track sections=[];
    @track fieldList=[];
    @track record = {};
    @track firstvalidate=false;
    @track sectionActive=[];
    @track objectType;

    connectedCallback() {       
        this.recordId = this.getQueryParameters();
        console.log('AA');
        getRecord({recordId:this.recordId, objectType: this.objectType})
        .then(results => {
            console.log('Risultato');
            let recRDO =results.rdo;
            for(let i = 0; i <recRDO.length; i++){
                let self = this;
                Object.keys(recRDO[i]).forEach( key => self.record[key] = recRDO[i][key] )
            }
            results.sectionList.forEach(result=>{
                this.createSection(result);
            })
            console.log('Sezioni Create');
            this.stopSpinner();
        })
        .catch()
        .finally(() => {
            console.log(this.template.querySelectorAll('.accordion'));
        })
        
    }
    
    createSection(sec){
        var fieldList = []
        for(var i=0; i<sec.FieldList.length; i++){
            var singleField = sec.FieldList[i];
            this.fieldList.push(singleField.ApiName);
            var isText= singleField.Type=='String';
            var isDateTime= singleField.Type=='DateTime';
            var isUrl= singleField.Type=='url'
            var isTextArea= singleField.Type=='Textarea'
            var isNumber= singleField.Type=='number'
            fieldList.push(
                {   label: singleField.Label,
                    value: isDateTime?Date.parse(this.record[singleField.ApiName]):this.record[singleField.ApiName], 
                    name: singleField.ApiName,
                    isText:isText, 
                    isUrl:isUrl,
                    isDateTime:isDateTime,
                    isTextArea:isTextArea,
                    isNumber:isNumber}
            )
        }  
        var section = new Object;
        section.fields      =   fieldList;
        section.sectionName =   sec.Nome;   
        this.sectionActive.push(sec.Nome);          
        this.sections.push(section);
    }
    getQueryParameters() {
        
        var search = window.location.href;
        var id = search.split('/')[6];
        this.objectType = search.split('/')[5];
        console.log('params: '+id);
        console.log('BBB');
        return id;
    }
    clickOnAccordion(event){
        
        switch (event.target.name){
            case 'Intestatario Precedente': {
                this.firstvalidate=false;
                break;
            }
        }
        console.log('click accordion');
    }
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
    startSpinner(){       
        if(this.template.querySelector("c-hdt_spinner"))
        this.template.querySelector("c-hdt_spinner").start();
    }
    stopSpinner(){        
        this.template.querySelector("c-hdt_spinner").stop();
        this.disableAssistiveSpinner=false;    
    }
}