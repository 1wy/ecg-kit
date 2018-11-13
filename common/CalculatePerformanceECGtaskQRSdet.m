%% (Internal) Calculate the performance data of a QRS detection task.
% This function is used by the ECGtask related with QRS detection to
% calculate performance of detectors.
%   
% Example
% 
%   payload_out = CalculatePerformanceECGtaskQRSdet(payload_out, ECG_annotations, ECG_header);
% 
% Arguments:
%     +payload_out: Internal payload with all detections
% 
%     +ECG_annotations: Gold standard to calculate performances. 
% 
%     +ECG_header: ECG header information. 
% 
%     +ECG_start_offset: Offset from ECG start. 
% 
% Output:
%     + payload: payloads generated by ECGtask_QRS_Detection.Process result
%        of concatenating plA and plB.
% 
% See also ECGtask_QRS_Detection
% 
% Author: Mariano Llamedo Soria llamedom@electron.frba.utn.edu.ar
% Version: 0.1 beta
% Last update: 06/10/2015
% Birthdate  : 06/10/2015
% Copyright 2008-2015
function payload_out = CalculatePerformanceECGtaskQRSdet(payload_out, ECG_annotations, ECG_header, ECG_start_offset)

    if( isempty(payload_out) || isempty(ECG_annotations) )
        return
    end

    AnnNames = payload_out.series_quality.AnnNames(:,1);
    cant_lead_name = size(AnnNames,1);
    payload_out.series_performance.conf_mat = zeros(2,2,cant_lead_name);
    payload_out.series_performance.error = nan(cant_lead_name,2);

    if(isempty(ECG_annotations)) 
        disp_string_framed(2, sprintf('Trusted references not found for %s', ECG_header.recname) );
    else
        % offset refs, produced anns were already shifted
<<<<<<< HEAD
        %ECG_annotations.time = ECG_annotations.time + ECG_start_offset - 1;
        ECG_annotations.time = ECG_annotations.time(ECG_annotations.time >= ECG_start_offset & ...
            ECG_annotations.time <= ECG_header.nsamp + ECG_start_offset);
=======
        ECG_annotations.time = ECG_annotations.time + ECG_start_offset - 1; 
>>>>>>> d452e1b8ed4f5f7a5e1fc0fb20aa75b8429d2e70
        
        payload_out.series_performance.conf_mat_details = cell(cant_lead_name,4);
        
        for kk = 1:cant_lead_name
            this_lead_det = payload_out.(AnnNames{kk}).time;
            [payload_out.series_performance.conf_mat(:,:,kk), ... 
                TP_gs_idx, ...
                TP_det_idx, ...
                FN_idx, ...
                FP_idx ] = bxb(ECG_annotations, this_lead_det, ECG_header );
            
            % details about the confusion matrix
            payload_out.series_performance.conf_mat_details(kk,:) = { TP_gs_idx, TP_det_idx, FN_idx, FP_idx };
            
            % meadian/mad of the error wrt the gold standard
            if( ~isempty(TP_det_idx) )
                aux_val = (colvec(this_lead_det(TP_det_idx)) - colvec(ECG_annotations.time(TP_gs_idx)));
                payload_out.series_performance.error(kk,:) = [ median(aux_val) mad(aux_val) ] /ECG_header.freq;
            end
        end            
    end
    