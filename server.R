#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    checkLowUp<-function(x){
        if(x!=''){
            g1<-tolower(strsplit(x,split = ' ')[[1]])
            g2<-strsplit(paste(toupper(substring(g1, 1,1)), substring(g1, 2),
                               sep="", collapse=" "),split=' ')[[1]]
            mat<-matrix(c(g1,g2),ncol=length(g1),byrow=T)
            obj<-matrix(NA,nrow=2^ncol(mat),ncol=ncol(mat))
            if(ncol(mat)>1){
                obj[,1]<-mat[,1]
                for(i in 2:ncol(mat)){
                    obj2<-expand.grid(unique(obj[,1:(i-1),drop=F])[,i-1],mat[,i],stringsAsFactors = F)
                    obj[,i]<-obj2[,2]
                }
            }else obj <- mat
            return(apply(obj,1,paste,sep=' ',collapse=' '))
        }
        else return(x)
    }
    firstUp<-function(x){
        y<-strsplit(x,split=' ')[[1]]
        paste(toupper(substring(y, 1,1)), substring(y, 2),sep="", collapse=" ")
    }
    
    Books<-read.csv('books.csv',stringsAsFactors = F)
    names(Books)<-c("ID",'Title','Author(s)','Rating','ISBN','ISBN13','Language','Pages','Total ratings','Total text reviews')
    library(dplyr)
    Books<-as_tibble(Books)
    Books$Rating<-as.numeric(Books$Rating)
    Books$Pages<-as.integer(Books$Pages)
    Books<-Books%>%
        arrange(desc(`Total ratings`),Title)
    Books$Rank<-rank(abs(5-Books$Rating),na.last=T,ties.method='min')
    Books$Top<-paste(floor(percent_rank(Books$Rating)*100),'%',sep='')
    #Qualquer possibilidade
    comb<-eventReactive(input$search,checkLowUp(input$title))
    ind.title<-reactive(apply(sapply(comb(),grepl,Books$Title),1,any))
    #Garantir maiusculas
    comb2<-eventReactive(input$search,firstUp(input$author))
    ind.aut<-reactive(grepl(comb2(),Books$`Author(s)`))
    Table<-reactive(Books%>%
        filter(ind.aut() & ind.title())%>%
        select(Title,`Author(s)`,Pages,Rating,Rank,Top,`Total ratings`,`Total text reviews`,Language))
    observeEvent(input$search,{
        output$table<-renderTable({Table()})
    })

    library(plotly)
    output$distPlot <- renderPlotly({

        Table()%>%
            plot_ly(x=Table()$Pages,y=Table()$`Total ratings`,z=Table()$Rating,type='scatter3d',
                    mode='markers',color=as.factor(Table()$Language),colors = 'YlOrRd',opacity=.8,
                    text=~paste('Title:', Table()$Title,
                                '</br> Author(s):', Table()$`Author(s)`),
                    marker=list(
                        size=6
                    )) %>%
            layout(title = "<B> Book characteristics </B> <br> (Legend shows book language)",
                   scene = list(
                       xaxis = list(title = "Number of pages"), 
                       yaxis = list(title = "Number of ratings"), 
                       zaxis = list(title = "Rating")))

    })

})
