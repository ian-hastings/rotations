#' insecticide_switch choose a new insecticide to switch to
#'
#' only gets called if insecticide_check() has already identified that the previous insecticide needed to be changed.   
#' Checks that the new insecticide is below resistance or survival thresholds.
#' 
#' @param RAF array of resistance allele frequencies
#' @param current_insecticide id number of current insecticide
#' @param n_insecticides number of insecticides (and hence loci)
#' @param threshold trigger for change of insecticide, either resistance frequency or mortality dependent on mort_or_freq, also precludes switch to an insecticide.
#' @param mort_or_freq whether threshold for insecticide change is mortality 'mort' or resistance frequency 'freq'
#' @param gen generation number
#' @param min_gens_switch_back minimum num gens before can switch back to an insecticide
#' @param df_ins number of generations since each insecticide used
#' @param df_results results of sim so far
#' @param diagnostics whether to output running info
# @param rot_interval frequency of rotation (in generations) NB if set to zero mean RwR i.e. rotate when resistant
# @param rot_count num generations this insecticide has been used for
#' @param eff effectiveness, for all insecticides or individually
#' @param dom_sel dominance of selection, for all insecticides or individually
#' @param rr resistance restoration, for all insecticides or individually 
#' 
# @examples 
#' 
#' @return integer : insecticide number to switch to, if 0 none found 
#' @export


insecticide_switch <- function( RAF,
                                current_insecticide,
                                n_insecticides,
                                threshold,
                                mort_or_freq,
                                gen,
                                min_gens_switch_back,
                                df_ins,
                                df_results,
                                diagnostics,
                                eff,
                                dom_sel,
                                rr )
{
  next_insecticide_found <- FALSE
  candidate <- current_insecticide 

  # for mortality convert mort thresh to survival
  # then check is if value is < survival same as for frequency
  # before 20/8/19 nasty bug that this conversion was in look below and got repeated
  if (mort_or_freq == 'mort') threshold <- 1-threshold

  for(temp_int in 1:n_insecticides)
  {
    #search through insecticides and go back to start if reach end
    candidate <- ifelse(candidate==n_insecticides, yes=1, no=candidate+1)
    
    # 26/2/19 allow mortality-based change criteria
    
    # set from resistance frequency first
    check_value <- RAF[candidate, 'f','intervention',gen] 
    
    # convert to survival if mortality option is selected
    # BEWARE mort-survival conversion
    # then check is if value is < survival same as for frequency
    if (mort_or_freq == 'mort')
    {
      check_value <- 1-mort_from_resist(rfreq=check_value, eff=eff, dom_sel=dom_sel, rr=rr ) 
      #don't want the below causes nasty bug due to multiple insecticides, fixed by moving above outside loop
      #threshold <- 1-threshold
    }

    # only switch to an insecticide that has lower frequency or survival than threshold
    if (check_value < threshold & 
        #optional condition of not going back to recently used insecticide
        #BEWARE this can cause unexpected behaviour
        df_ins$last_used[candidate] >= min_gens_switch_back )
    {
      
      if (diagnostics) 
      {
        if (mort_or_freq == 'mort')
        {
          message(sprintf("generation %d, switch from insecticide %d to %d; new mortality vs threshold = %f vs %f",
                          gen, current_insecticide, candidate,
                          check_value, threshold)) 
        } else
        {
          message(sprintf("generation %d, switch from insecticide %d to %d; new frequency vs threshold = %f and %f",
                          gen, current_insecticide, candidate,
                          check_value, threshold))           
        }
      }

      
      next_insecticide_found <- TRUE 
      current_insecticide <- candidate 
    }
    
    if (next_insecticide_found) break   
    
  } # end of loop checking each insecticide
 
# return 0 if no insecticide to use next found  
if (!next_insecticide_found) current_insecticide <- 0 
   
return(current_insecticide)  
}