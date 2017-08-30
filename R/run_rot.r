#' run_rot to run simulation of the effect of rotations on the spread of resistance
#'
#' can run any number of insecticides/loci 
#' but at present, input will only allow a maximumum of 5
#' 
#' @param max_generations maximum number of mosquito generations to run the simulation
#' @param n_insecticides MAX is 5<<<<the number of insecticides (and hence loci) in the simuation MAX IS 5<<<
#' @param rotation_interval frequency of rotation (in generations) NB if set to zero mean RwR i.e. rotate when resistant
#' @param rotation_criterion resistant allele frequency that triggers a RwR change or precludes a insecticide from being rotated in.
#' @param migration_rate_intervention migration rate into and out-of the treated area. It is the proportion of the treated population that migrates. We assume that immigration=emigration.
#' @param coverage proportion of mosquitoes that are covered by the intervention (and 1-C is the proportion of the population in the untreated refugia).
#' @param plot whether to plot results
#' @param diagnostics whether to output running info
#' 
#' @examples 
#' run_rot(rotation_interval=100)
#' df_res2 <- run_rotation()
#' 
#' @import tidyverse 
#' @return dataframe of results
#' @export


run_rot <- function( max_generations = 500, #the maximum number of mosquito generations to run the simulation
                          n_insecticides = 4, #MAX is 5<<<<the number of insecticides (and hence loci) in the simuation MAX IS 5<<<
                          
                          rotation_interval = 0, #frequency of rotation (in generations) NB if set to zero mean RwR i.e. rotate when resistant
                          rotation_criterion = 0.5, #resistant allele frequency that triggers a RwR change or precludes a insecticide from being rotated in.
                          
                          migration_rate_intervention = 0.01, # migration rate into and out-of the treated area. It is the proportion of the treated population that migrates. We assume that immigration=emigration.
                          coverage = 0.8, # "coverage" of the intervention is defined as the proportion of mosquitoes that are covered by the intervention (and 1-C is the proportion of the population in the untreated refugia).
                          plot = TRUE,
                          diagnostics = FALSE
                          )
  {
  
  migration_rate_refugia=migration_rate_intervention*coverage/(1-coverage)  
    
  #RAF stands for resistance allele frequency
  RAF <-      array_named(insecticide=1:n_insecticides, sex=c('m','f'), site=c('intervention','refugia'), gen=1:max_generations)
  exposure <- array_named(insecticide=1:n_insecticides, sex=c('m','f'), amount=c('no','lo', 'hi'))
  fitness <-  array_named(insecticide=1:n_insecticides, genotype=c('SS','SR', 'RR'), amount=c('no','lo', 'hi'))
  results <-  array(0, dim=c(max_generations, 12))
  
  #andy try to store results in data frame might make easier
  df_results <- data.frame(generation=1:max_generations,
                      insecticide=NA,
                      r1_active=NA,
                      r1_refuge=NA,
                      r2_active=NA,
                      r2_refuge=NA,
                      r3_active=NA,
                      r3_refuge=NA,
                      r4_active=NA,
                      r4_refuge=NA,
                      r5_active=NA,
                      r5_refuge=NA, stringsAsFactors = FALSE)
  #experimental
  # df_res_active <- data.frame(generation=rep(1:max_generations,n_insecticides),
  #                       insecticide=NA,
  #                       region=NA,
  #                       resistance=NA, stringsAsFactors = FALSE)
  # df_res_refuge <- df_res_active
  
  
  #inital resistance allele frequency (i.e. generation 1) in the intervention and refugia
  #locus 1>>
  RAF[1, 'm', 'intervention',1]=0.002;  RAF[1, 'f', 'intervention',1]=0.002;
  RAF[1, 'm', 'refugia',1]=0.001;       RAF[1, 'f', 'refugia',1]=0.001
  #locus 2>>
  if(n_insecticides>=2){ #need to avoid exceeding size of the array
    RAF[2, 'm', 'intervention',1]=0.001;   RAF[2, 'f', 'intervention',1]=0.001;
    RAF[2, 'm', 'refugia',1]=0.001;        RAF[2, 'f', 'refugia',1]=0.001
  }
  #locus 3>>
  if(n_insecticides>=3){
    RAF[3, 'm', 'intervention',1]=0.09;  RAF[3, 'f', 'intervention',1]=0.09;
    RAF[3, 'm', 'refugia',1]=0.001;       RAF[3, 'f', 'refugia',1]=0.001
  }
  #locus 4>>
  if(n_insecticides>=4){
    RAF[4, 'm', 'intervention',1]=0.09;  RAF[4, 'f', 'intervention',1]=0.09;
    RAF[4, 'm', 'refugia',1]=0.001;       RAF[4, 'f', 'refugia',1]=0.001
  }#locus 5>>
  if(n_insecticides>=5){
    RAF[5, 'm', 'intervention',1]=0.09; RAF[5, 'f', 'intervention',1]=0.09;
    RAF[5, 'm', 'refugia',1]=0.001;      RAF[5, 'f', 'refugia',1]=0.001
  }
  
  
  # andy looking to set fitnesses for all insecticides to be same
  # but it seemed to mess up simulation
  # so disabled for now
  # fitness[, 'SS', 'no']=0.3; fitness[, 'SS', 'lo']=0.3; fitness[, 'SS', 'hi']=0.3;
  # fitness[, 'SR', 'no']=0.3; fitness[, 'SR', 'lo']=0.7; fitness[, 'SR', 'hi']=0.7;
  # fitness[, 'RR', 'no']=0.3; fitness[, 'RR', 'lo']=0.9; fitness[, 'RR', 'hi']=0.9;
  
  #genetic data for locus 1
  fitness[1, 'SS', 'no']=0.1; fitness[1, 'SS', 'lo']=0.3; fitness[1, 'SS', 'hi']=0.3;
  fitness[1, 'SR', 'no']=0.1; fitness[1, 'SR', 'lo']=0.7; fitness[1, 'SR', 'hi']=0.7;
  fitness[1, 'RR', 'no']=0.1; fitness[1, 'RR', 'lo']=0.9; fitness[1, 'RR', 'hi']=0.9;
  #genetic data for locus 2
  if(n_insecticides>=2){
  fitness[2, 'SS', 'no']=0.3; fitness[2, 'SS', 'lo']=0.3; fitness[2, 'SS', 'hi']=0.3;
  fitness[2, 'SR', 'no']=0.3; fitness[2, 'SR', 'lo']=0.8; fitness[2, 'SR', 'hi']=0.8;
  fitness[2, 'RR', 'no']=0.3; fitness[2, 'RR', 'lo']=0.9; fitness[2, 'RR', 'hi']=0.9;
  }
  #genetic data for locus 3
  if(n_insecticides>=3){
  fitness[3, 'SS', 'no']=0.3; fitness[3, 'SS', 'lo']=0.3; fitness[3, 'SS', 'hi']=0.3;
  fitness[3, 'SR', 'no']=0.3; fitness[3, 'SR', 'lo']=0.3; fitness[3, 'SR', 'hi']=0.3;
  fitness[3, 'RR', 'no']=0.3; fitness[3, 'RR', 'lo']=0.3; fitness[3, 'RR', 'hi']=0.3;
  }
  #genetic data for locus 4
  if(n_insecticides>=4){
  fitness[4, 'SS', 'no']=0.3; fitness[4, 'SS', 'lo']=0.3; fitness[4, 'SS', 'hi']=0.3;
  fitness[4, 'SR', 'no']=0.3; fitness[4, 'SR', 'lo']=0.4; fitness[4, 'SR', 'hi']=0.4;
  fitness[4, 'RR', 'no']=0.3; fitness[4, 'RR', 'lo']=0.5; fitness[4, 'RR', 'hi']=0.5;
  }#genetic data for locus 5
  if(n_insecticides>=5){
  fitness[5, 'SS', 'no']=0.3; fitness[5, 'SS', 'lo']=0.3; fitness[5, 'SS', 'hi']=0.3;
  fitness[5, 'SR', 'no']=0.3; fitness[5, 'SR', 'lo']=0.3; fitness[5, 'SR', 'hi']=0.3;
  fitness[5, 'RR', 'no']=0.3; fitness[5, 'RR', 'lo']=0.3; fitness[5, 'RR', 'hi']=0.3;
  }
  
  # <<<<<<<<<<<<< end of user-defined variable >>>>>>>>>>>>>>>>>>>>>>>>
  
  ################### now to check input value are sensible, lie within their limits, etc #######################################
  
  #>>>Now check that exposure(none) is not less than zero
  for(temp_int in 1:n_insecticides){
    if (exposure[temp_int, 'm', 'no']<0) message(sprintf("warning from calibration: m exposure to no insecticide %d is <0\n", temp_int)) 
    if (exposure[temp_int, 'f', 'no']<0) message(sprintf("warning from calibration: f exposure to no insecticide %d is <0\n", temp_int)) 
  }
  
  if(migration_rate_intervention>(1-coverage)){
  message(sprintf("warning from calibration: migration rate in/out of intervenation exceed 1 minus coverage\n"))   
  }
  
  
  
  #>>>>>>>> now to run the simulations <<<<<<<<<<<<<<<<<<<<<<<<<<<
  
  current_insecticide=1 #usually start the rotation sequence at #1 but can specify any one start
  next_insecticide_found=1
  change_insecticide=0;
  rotation_count=1
  
  results[1,1]=1; results[1,2]=current_insecticide;
  
  for(gen in 2:max_generations)
  { #start at generation 2 because generation 1 holds the user-defined initial allele frequenciess
    
  
  for(insecticide in 1:n_insecticides){
  
  #first the intervention site  
   if(insecticide==current_insecticide){ #i.e. insecticide selection taking place
     
     coeff_1=
       (  RAF[insecticide, 'm', 'intervention',gen-1]*(1-RAF[insecticide, 'f', 'intervention',gen-1])+
       (1-RAF[insecticide, 'm', 'intervention',gen-1]) * RAF[insecticide, 'f', 'intervention',gen-1])*0.5
  
     coeff_2=
       exposure[insecticide, 'm', 'no']*fitness[insecticide, 'SR', 'no']+
       exposure[insecticide, 'm', 'lo']*fitness[insecticide, 'SR', 'lo']+
       exposure[insecticide, 'm', 'hi']*fitness[insecticide, 'SR', 'hi']
     #todo andy this does same with less code
     #sum( exposure[insecticide, 'm', ]*fitness[insecticide, 'SR', ] )
      
     coeff_3=
       exposure[insecticide, 'f', 'no']*fitness[insecticide, 'SR', 'no']+
       exposure[insecticide, 'f', 'lo']*fitness[insecticide, 'SR', 'lo']+
       exposure[insecticide, 'f', 'hi']*fitness[insecticide, 'SR', 'hi']
     #todo andy this does same with less code
     #sum( exposure[insecticide, 'f', ]*fitness[insecticide, 'SR', ] )
       
  #Eqn 4: first the m resistant alleles>>
    temp_coeff=
      exposure[insecticide, 'm', 'no']*fitness[insecticide, 'RR', 'no']+
      exposure[insecticide, 'm', 'lo']*fitness[insecticide, 'RR', 'lo']+
      exposure[insecticide, 'm', 'hi']*fitness[insecticide, 'RR', 'hi']
        
    F_male_r_intervention=
      RAF[insecticide, 'm', 'intervention', gen-1]*RAF[insecticide, 'f', 'intervention', gen-1]*temp_coeff+
      coeff_1*coeff_2
    
    #Eqn 5: now the male sensitive alleles>> 
    temp_coeff=
      exposure[insecticide, 'm', 'no']*fitness[insecticide, 'SS', 'no']+
      exposure[insecticide, 'm', 'lo']*fitness[insecticide, 'SS', 'lo']+
      exposure[insecticide, 'm', 'hi']*fitness[insecticide, 'SS', 'hi']
     
  F_male_s_intervention=
  (1-RAF[insecticide, 'm', 'intervention',gen-1])*(1-RAF[insecticide, 'f', 'intervention', gen-1])*temp_coeff+
  coeff_1*coeff_2
  
  #now normalise the male gamete frequencies and store the results
  norm_coeff=F_male_r_intervention+F_male_s_intervention
  RAF[insecticide, 'm', 'intervention', gen]=F_male_r_intervention/norm_coeff
  
      
    #now the f resistant alleles>>
    temp_coeff=
      exposure[insecticide, 'f', 'no']*fitness[insecticide, 'RR', 'no']+
      exposure[insecticide, 'f', 'lo']*fitness[insecticide, 'RR', 'lo']+
      exposure[insecticide, 'f', 'hi']*fitness[insecticide, 'RR', 'hi']
   
    F_female_r_intervention=
    RAF[insecticide, 'm', 'intervention', gen-1]*RAF[insecticide, 'f', 'intervention',gen-1]*temp_coeff+
      coeff_1*coeff_3
    
    #now the female sensitive alleles>> 
    temp_coeff=
      exposure[insecticide, 'f', 'no']*fitness[insecticide, 'SS', 'no']+
      exposure[insecticide, 'f', 'lo']*fitness[insecticide, 'SS', 'lo']+
      exposure[insecticide, 'f', 'hi']*fitness[insecticide, 'SS', 'hi']
        
   F_female_s_intervention=
  (1-RAF[insecticide, 'm', 'intervention', gen-1])*(1-RAF[insecticide, 'f', 'intervention',gen-1])*temp_coeff+
  coeff_1*coeff_3 
  
   
    #now normalise the female gamete frequencies and store the results
    norm_coeff=F_female_r_intervention+F_female_s_intervention
    RAF[insecticide, 'f', 'intervention', gen]=F_female_r_intervention/norm_coeff
    
    if(diagnostics) message(sprintf("generation %d: just completed insecticide selection for locus/insecticide %d\n", gen, insecticide))
    
    
  } #end of loop that deals with this insecticide if it is being deployed
    
   else{ #i.e no selection for this insecticide in the intervention site
     #first the coefficient for heterozygotes common to equations 2 and 3
     temp_coeff=
       (RAF[insecticide, 'm', 'intervention',gen-1]*(1-RAF[insecticide, 'f', 'intervention',gen-1])+
       RAF[insecticide, 'f', 'intervention',gen-1]*(1-RAF[insecticide, 'm', 'intervention',gen-1]))*
       0.5*fitness[insecticide, 'SR', 'no']
                  
     
  #now the resistant and sensitive frequencies in untreated areas  
     F_male_r_intervention=RAF[insecticide, 'm', 'intervention',gen-1]*RAF[insecticide, 'f', 'intervention', gen-1]*fitness[insecticide, 'RR', 'no']+temp_coeff
     F_male_s_intervention=(1-RAF[insecticide, 'm', 'intervention',gen-1])*(1-RAF[insecticide, 'f', 'intervention',gen-1])*fitness[insecticide, 'SS', 'no']+temp_coeff
     #now to normalise them
     norm_coeff= F_male_r_intervention+F_male_s_intervention
     RAF[insecticide, 'm', 'intervention', gen]=F_male_r_intervention/norm_coeff
    
  
  #same allele frequencies in both sexes if no differential exposure so 
     RAF[insecticide, 'f', 'intervention', gen]=RAF[insecticide, 'm', 'intervention', gen]
    if(diagnostics) message(sprintf("generation %d: just completed natural selection against locus %d in intervention site\n", gen, insecticide))   
        
   
     } #end of code for insecticides that are not being deployed  in the intervention site
      
  #now for the refugia
    #first the coefficient for heterozygotes common to equations 2 and 3
    temp_coeff=(RAF[insecticide, 'm', 'refugia',gen-1]*(1-RAF[insecticide, 'f', 'refugia',gen-1])+
                  RAF[insecticide, 'f', 'refugia',gen-1]*(1-RAF[insecticide, 'm','refugia',gen-1]))*
      0.5*fitness[insecticide, 'SR', 'no']
    
   
     #now the resistant and sensitive frequencies   
    F_male_r_refugia=RAF[insecticide, 'm', 'refugia',gen-1]*RAF[insecticide, 'f', 'refugia',gen-1]*
      fitness[insecticide, 'RR', 'no']+temp_coeff
    F_male_s_refugia=(1-RAF[insecticide, 'm', 'refugia',gen-1])*(1-RAF[insecticide, 'f', 'refugia', gen-1])*
      fitness[insecticide, 'SS', 'no']+temp_coeff 
    
    #now to normalise them and store the results
    norm_coeff= F_male_r_refugia+F_male_s_refugia
    RAF[insecticide, 'm', 'refugia', gen]=F_male_r_refugia/norm_coeff
    #same allele frequencies in both sexes if no differential selection so
    RAF[insecticide, 'f', 'refugia', gen]=RAF[insecticide, 'm', 'refugia', gen]
    
    if(diagnostics) message(sprintf("generation %d: just completed natural selection against locus %d in refugia\n", gen, insecticide))
    
  }   #end of cycling insecticides
  
    
  #now for migration between refugia and intervention site
  
  for(temp_int in 1:n_insecticides){ 
      
   fem_intervention=
     (1-migration_rate_intervention)*RAF[temp_int, 'f', 'intervention', gen]+
     migration_rate_intervention*RAF[temp_int, 'f', 'refugia', gen]
    
   male_intervention=
     (1-migration_rate_intervention)*RAF[temp_int, 'm', 'intervention', gen]+
     migration_rate_intervention*RAF[temp_int, 'm', 'refugia', gen]
   
   fem_refugia=
     (1-migration_rate_refugia)*RAF[temp_int, 'f', 'refugia', gen]+
     migration_rate_refugia*RAF[temp_int, 'f', 'intervention', gen]
   
   male_refugia=
     (1-migration_rate_refugia)*RAF[temp_int, 'm', 'refugia', gen]+
     migration_rate_refugia*RAF[temp_int, 'm', 'intervention', gen]
   
  RAF[temp_int, 'f', 'intervention', gen]=fem_intervention
  RAF[temp_int, 'm', 'intervention', gen]=male_intervention 
  RAF[temp_int, 'f', 'refugia', gen]=fem_refugia
  RAF[temp_int, 'm', 'refugia', gen]=male_refugia
  
   } #end of cycling migration for each insecticide
    
    
  #now to find if we need to switch current insecticide
    if(rotation_interval==0){  #i.e.  its a RwR policy:
          if(RAF[current_insecticide, 'f','intervention', gen] > rotation_criterion) change_insecticide=1
          #message(sprintf("confirm. RAF=%f, change_insecticide=%d \n", RAF[current_insecticide, 'f','intervention', gen], change_insecticide))
          }  
    
  if(rotation_interval!=0){ #i.e. if freq_rotation>0 then its a policy of routine, periodic rotation
  #NOTE. At the moment if all but one of the insecticides are over the thereshold frequency, the one under the threshold
  #will be repeatedly deployed. For example, if there are 3 insecticides and rotation is every 10 generations. 
  #if #3 is being deployed and due to rotate out at generetion 100: if only #3 is under the threshold
  #it will not rotate out, but will continue to be used util the next scheduled rotation at which point
    #(a) it will continue to be use if it is the only one below the threshold 
    #(b) it will be replaced if one of the other insecticides is now below the threshold due to fitness effects or migration
    #(c) the simulation will terminate if all insecticides exceed the threshold
      
  if (rotation_count!=rotation_interval) rotation_count=rotation_count+1
  else change_insecticide=1 #i.e. its time to rotate so need to identify the next insecticide in the rotation
  }
    
  if(change_insecticide==1){
  rotation_count=1; next_insecticide_found=0; candidate=current_insecticide 
              
  for(temp_int in 1:n_insecticides){
    if(candidate==n_insecticides) candidate=1 else candidate=candidate+1 
    if(RAF[candidate, 'f','intervention', gen]<rotation_criterion){
      message(sprintf("generation %d, switching from insecticide %d to insecticide %d; RAF are %f and %f respectively\n",
                      gen, current_insecticide, candidate,
                      RAF[current_insecticide, 'f','intervention', gen], RAF[candidate, 'f','intervention', gen]))
      next_insecticide_found=1; current_insecticide=candidate; change_insecticide=0
        }
  if(next_insecticide_found==1) break
  } #end of temp_int loop
  } #end of loop to try and change insecticide i.e. the "if(change_insecticide==1)" lopp
  
  #now to store some results for ease of plotting (see later) before potentially terminating the simulation
  results[gen,1]=gen; 
  results[gen,2]=current_insecticide
  
  df_results$insecticide[gen] <- current_insecticide 
  
  if(next_insecticide_found==0){
  message(sprintf("simulation terminating at generation %d because all RAFs above threshold of %f\n", gen,  rotation_criterion))
    for(temp_int in 1:n_insecticides){
      message(sprintf("frequency of resistance in females to insecticide %d is %f\n", temp_int, RAF[temp_int, 'f','intervention', gen]))  
    }
  break #breaks out of looping generations and terminates the simulation
  }    
    
   } #end of cycle running the gens up to max_generations
    
  #****************************************************************  
   # NOW collate the data and draw plots
  
  #andy trying to replace below with data frame  
  #also can probably do on whole row so not require the loop
  for(i_num in 1:n_insecticides)
  {
    df_results[[paste0('r',i_num,'_active')]] <- 0.5*(RAF[i_num, 'm','intervention', ]+
                                                      RAF[i_num, 'f','intervention', ])
    df_results[[paste0('r',i_num,'_refuge')]] <- 0.5*(RAF[i_num, 'm','refugia', ]+
                                                      RAF[i_num, 'f','refugia', ]) 
    
    #df_res_active$region[[(i_num-1)*max_generations:(i_num)*max_generations]] <- paste0("insecticide",i_num)
    #df_res_active$resistance[[(i_num-1)*max_generations:(i_num)*max_generations]] <-  0.5*(RAF[i_num, 'm','intervention', ]+
    #                                                                                             RAF[i_num, 'f','intervention', ])
  }
  #but if I want to facet by intervention may want to structure differently
  #generation, treatment, resistance
  df_res2 <- df_results %>%
    gather('r1_refuge', 'r1_active',
           'r2_refuge', 'r2_active',
           'r3_refuge', 'r3_active',
           'r4_refuge', 'r4_active',
           #'r5_refuge', 'r5_active', 
           key=region, value=resistance)
  
  for(temp_int in 1:max_generations){
  
  results[temp_int,3]=0.5*(RAF[1, 'm','intervention', temp_int]+RAF[1, 'f','intervention', temp_int]) #locus 1
  results[temp_int,4]=0.5*(RAF[1, 'm','refugia', temp_int]+RAF[1, 'f','refugia', temp_int]) #locus 1
  if(n_insecticides>=2){
  results[temp_int,5]=0.5*(RAF[2, 'm','intervention', temp_int]+RAF[2, 'f','intervention', temp_int]) #locus 2
  results[temp_int,6]=0.5*(RAF[2, 'm','refugia', temp_int]+RAF[2,'f','refugia', temp_int]) #locus 2
  }
  if(n_insecticides>=3){
  results[temp_int,7]=0.5*(RAF[3, 'm','intervention', temp_int]+RAF[3, 'f','intervention', temp_int]) #locus 3
  results[temp_int,8]=0.5*(RAF[3, 'm','refugia', temp_int]+RAF[3, 'f','refugia', temp_int]) #locus 3
  }
  if(n_insecticides>=4){
  results[temp_int,9]=0.5*(RAF[4, 'm','intervention', temp_int]+RAF[4, 'f','intervention', temp_int]) #locus 4
  results[temp_int,10]=0.5*(RAF[4, 'm','refugia', temp_int]+RAF[4,'f','refugia', temp_int]) #locus 4
  }
  if(n_insecticides>=5){
  results[temp_int,11]=0.5*(RAF[5, 'm','intervention', temp_int]+RAF[5, 'f','intervention', temp_int]) #locus 5
  results[temp_int,12]=0.5*(RAF[5, 'm','refugia', temp_int]+RAF[5, 'f','refugia', temp_int]) #locus 5
  }
  
  } #end of temp_int loop
  
  # do the plots
  #rot_plot_use(df_res2)
  rot_plot_resistance(df_res2)
  
  invisible(df_res2)
  
} # end of run_rotation()


