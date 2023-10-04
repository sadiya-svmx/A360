import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class SetupHome extends NavigationMixin(LightningElement) {
    @track selectedMenuItem = "mapping_rules";
    @track selectedComponent;
    @track isAdminScreen = false;
    @track isLookupEditor = false;
    @track apiInProgress = true;

    isAutoConfigRunning = false;
    cardLess = false;

    @wire(CurrentPageReference)
    setCurrentPageReference (pageRef) {
        if (pageRef && pageRef.state) {
            if (pageRef.state.c__currentItem) {
                this.selectedMenuItem = pageRef.state.c__currentItem;
                this.selectedComponent = pageRef.state.c__target;
            }
            if (pageRef.state.c__isLookupEditor === 'true') {
                this.isLookupEditor = true;
            } else {
                this.isAdminScreen = true;
                this.isLookupEditor = false;
            }
        }
    }

    openAdminScreen () {
        this.isAdminScreen = true;
        this.isLookupEditor = false;
    }

    handleComplete () {
        this.apiInProgress = false;
    }

    handleLoadPage (event) {
        const {
            cardLess = false,
            isAutoConfigRunning = false
        } = event.detail ?  event.detail : {};
        this.cardLess = cardLess;
        this.isAutoConfigRunning = isAutoConfigRunning;
        if (isAutoConfigRunning) {
            this.apiInProgress = false;
        }
    }
}