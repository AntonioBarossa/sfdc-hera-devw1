import { LightningElement, api, track , wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import saveCase from '@salesforce/apex/HDT_LC_CambioUso.updateCase';

export default class HdtCambioUso extends NavigationMixin(LightningElement){
    @api processtype;
    @api objectName = 'Case';
    @api recordid;
    @api accountId;
    @api saveButton;
    @api cancelButton;
    @api draftButton;
    @api acceptedFormats = ['.pdf', '.png'];
    @api statoApp = 'Nessuna Richiesta Inviata';
    @api saveInDraft;
    @api res = false;
    @api cancelCase;
    @api isRunFromFlow= false;
    @track showOperationSubType= false;
    @track selectedOperationType;
    @track showSubmitForApprovalButton=false;
    @track disableConfirmButton= false;
    @track preloading= false;
    addebitoOptions=[
        {label:'Si', value:'Si'},
        {label:'No', value:'No'}
    ];
    discochangevalue = [{label:'--None--', value:'--None--'}];
    discoTipoOptions=[
        {label:'01- App. medico terapeutiche', value:'01- App. medico terapeutiche'},
        {label:'02- Pubblica utilità', value:'02- Pubblica utilità'}
    ]

    fornituraOption =[
        {label:"Domestico", value:"Domestico"},
        {label:"Non Domestico", value:"Non Domestico"},
        {label:"A-Domestico", value:"A-Domestico"},
        {label:"B-Condominio", value:"B-Condominio"},
        {label:"C-Aziende di pubblica utilita", value:"C-Aziende di pubblica utilita"},
        {label:"D-Altri usi", value:"D-Altri usi"}
    ];

    impiantoOptions =[
        {label:"13A0-Usi di Abitazione BT", value:"13A0-Usi di Abitazione BT"},
        {label:"13BB-Illuminazione pubblica BT", value:"13BB-Illuminazione pubblica BT"},
        {label:"13CB-Non domestici in BT", value:"13CB-Non domestici in BT"},
        {label:"13CT-Forn temporanee < 21 gg", value:"13CT-Forn temporanee < 21 gg"},
        {label:"13DM-Illuminazione pubblica MT", value:"13DM-Illuminazione pubblica MT"},
        {label:"13EM-Non domestici MT", value:"13EM-Non domestici MT"},
        {label:"13FM-Non domestici AT", value:"13FM-Non domestici AT"}
        //{label:"13X0-Usi interni BT", value:"13X0-Usi interni BT"},
        //{label:"13Y0-Usi interni MT", value:"13Y0-Usi interni MT"},
        //{label:"13Z0-Grossisti", value:"13Z0-Grossisti"}
    ];
   
@api handleChange(event){
    
        this.res =  event.target.value;
}

@api handleChangeDisco(event){

    if('No' == event.target.value){
        this.discochangevalue = this.discoTipoOptions;
    }
    else{
        this.discochangevalue = [{label:'--None--', value:'--None--'}];
    }
    
}
    @api
    handleSave(){

        console.log('*****');
        
        let cambiouso =this.template.querySelector('[data-id="cambioUso"]').value;
        console.log('*****');
        let tipofornitura= this.template.querySelector('[data-id="tipoFornitura"]').value;
        console.log('*****');
        let recapito = this.template.querySelector('[data-id="recapito"]').value;
        console.log('*****');
        let tipoimpianto =this.template.querySelector('[data-id="TipoImpianto"]').value;
        console.log('*****');
        let disco = this.template.querySelector('[data-id="Disconnetibilita"]').value;
        let discoType = this.template.querySelector('[data-id="tipoDisconnetibilita"]').value;
      //  let residente= this.template.querySelector('[data-id="residente"]');
        console.log('*****');
        let note= this.template.querySelector('[data-id="note"]').value;
        console.log('*****');

        console.log('****:' + cambiouso);
        console.log('****:' + tipofornitura);
        console.log('****:' + recapito);
        console.log('****:' + tipoimpianto );
        console.log('****:' + this.res);
        console.log('****:' + note);

        saveCase({
            caseId : this.recordid, 
            addebito : cambiouso, 
            tipoFornitura : tipofornitura, 
            recapito : recapito, 
            tipoImpianto : tipoimpianto, 
            residente : this.res, 
            note : note,
            disco : disco,
            discotype : discoType
        }).then((response) => {
            if(response){

                const event = new ShowToastEvent({
                    message: 'Case Confermato',
                    variant: 'success',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    const closeclickedevt = new CustomEvent('closeaction');
                    this.dispatchEvent(closeclickedevt); 

            }else{

                const event = new ShowToastEvent({
                    message: 'Errore',
                    variant: 'error',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
            }
        });



    }


}