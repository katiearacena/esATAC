PeakCallingFseq <-R6Class(
    classname = "PeakCallingFseq",
    inherit = BaseProc,
    public = list(
        initialize = function(atacProc,bedInput=NULL,background=NULL,genomicReadsCount=NULL,
                              fragmentSize=0,featureLength=NULL,bedOutput=NULL,
                              outputFormat=c("bed","wig","npf"), ploidyDir=NULL,
                              wiggleTrackStep=NULL,threshold=NULL,verbose=TRUE,
                              wgThresholdSet=NULL,editable=FALSE){
            super$initialize("PeakCallingFseq",editable,list(arg1=atacProc))
            if(!is.null(atacProc)){
                if(!atacProc$getParam("merge")){
                    stop("The paired end data must be merged from Sam files");
                }
                private$paramlist[["bedInput"]] <- atacProc$getParam("bedOutput");
                private$paramlist[["bedFileList"]] <- basename(atacProc$getParam("bedOutput"));
                private$paramlist[["inputDir"]] <- dirname(atacProc$getParam("bedOutput"));
            }

            if(!is.null(bedInput)){
                private$paramlist[["bedInput"]] <- bedInput;
                private$paramlist[["bedFileList"]] <- basename(bedInput)
                private$paramlist[["inputDir"]] <- dirname(bedInput);
            }
            if(!is.null(bedOutput)){
                private$paramlist[["bedOutput"]] <-bedOutput
            }else{
                private$paramlist[["bedOutput"]] <-paste(private$paramlist[["bedInput"]],".peak.bed",sep="");
            }
            private$paramlist[["outputDir"]] <- paste(private$paramlist[["bedOutput"]],".tmp",sep="");

            private$paramlist[["background"]] <- background;
            private$paramlist[["genomicReadsCount"]] <- genomicReadsCount;
            private$paramlist[["fragmentSize"]] <- fragmentSize;
            private$paramlist[["featureLength"]] <- featureLength;
            private$paramlist[["outputFormat"]] <- outputFormat[1];
            private$paramlist[["ploidyDir"]] <- ploidyDir;
            private$paramlist[["wiggleTrackStep"]] <- wiggleTrackStep;
            private$paramlist[["threshold"]] <- threshold;
            private$paramlist[["verbose"]] <- verbose;
            private$paramlist[["wgThresholdSet"]] <- wgThresholdSet;

            private$checkFileExist(private$paramlist[["bedInput"]]);
            private$checkFileExist(private$paramlist[["background"]]);
            private$checkPathExist(private$paramlist[["ploidyDir"]]);
            private$checkFileCreatable(private$paramlist[["bedOutput"]]);

            private$checkRequireParam();
        },
        processing = function(){
            super$processing()
            dir.create(private$paramlist[["outputDir"]])
            result <- .fseq_call(bedFileList=private$paramlist[["bedFileList"]],
                                   background=private$paramlist[["background"]],
                                   genomicReadsCount=private$paramlist[["genomicReadsCount"]],
                                   inputDir=private$paramlist[["inputDir"]],
                                   fragmentSize=private$paramlist[["fragmentSize"]],
                                   featureLength=private$paramlist[["featureLength"]],
                                   outputDir=private$paramlist[["outputDir"]],
                                   outputFormat=private$paramlist[["outputFormat"]],
                                   ploidyDir=private$paramlist[["ploidyDir"]],
                                   wiggleTrackStep=private$paramlist[["wiggleTrackStep"]],
                                   threshold=private$paramlist[["threshold"]],
                                   verbose=private$paramlist[["verbose"]],
                                   wgThresholdSet=private$paramlist[["wgThresholdSet"]]);

        filename<-list.files(private$paramlist[["outputDir"]])
        for(i in 1:length(filename)){
            filename[i]<-strsplit(filename[i],split="\\.")[[1]][1]
        }
        peakfiles <- sort(filename)
        peakfiles<-paste0(peakfiles,".bed")
        peakfiles <- paste0(private$paramlist[["outputDir"]],"/",peakfiles)
        file.create(private$paramlist[["bedOutput"]])
        for(i in 1:length(peakfiles)){
            file.append(private$paramlist[["bedOutput"]],peakfiles[i])
        }
        #mergeFile(private$paramlist[["bedOutput"]],peakfiles)
        unlink(private$paramlist[["outputDir"]],recursive = TRUE,force = TRUE)
        private$finish <- TRUE
        },
        setResultParam = function(bedOutput){
            super$setResultParam();
            private$paramlist[["bedOutput"]] <- bedOutput
        }
    ),
    private = list(
        checkRequireParam = function(){
            if(private$editable){
                return();
            }
            if(is.null(private$paramlist[["bedInput"]])){
                stop("bedInput is required.")
            }
        }
    )


)