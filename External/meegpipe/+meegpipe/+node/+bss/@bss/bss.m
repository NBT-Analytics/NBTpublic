classdef bss < meegpipe.node.abstract_node
% BSS - Blind Source Separation node
%
% Nodes of class `bss` perform blind source separation on the input data, select
% a set of sources using an automatic criterion, and reject or accept the
% selected sources. Depending on the specific configuration, this node may be
% used to correct for many types of artifacts: powerline, cardiac artifacts,
% muscle and ocular artifacts, etc. It may also be used to filter out any M/EEG
% component that is not related to a specific brain process. E.g. it may be used
% to filter out any M/EEG component not related to the alpha rhythm.
%
% ## Construction
%
%   myNode = meegpipe.node.bss.new('ArgName', ArgValue, ...)
%
%
% ## Construction arguments
%
%
    methods (Static, Access = private)
        make_filtering_report(rep, icsIn, icsOut);

        % Used by make_bss_report()
        [maxVar, meanVar] = make_explained_var_report(rep, bss, ics, data, verb, verbL);
    end

    methods (Access = private)

        count = make_pca_report(obj, myPCA);

        count = make_criterion_report(obj, critObj, labels, icSel, isAutoSel);

        bssRep = make_bss_report(obj, bssObj, ics, data, icSel);

        extract_bss_features(obj, bssObj, ics, data, icSel);

        write_training_data_to_disk(obj, featVal);

        % These are called by make_bss_report()
        make_bss_object_report(obj, bss, ics, rep, verb, verbL);

        make_spcs_snapshots_report(obj, ics, rep, verb, verbL);

        make_spcs_psd_report(obj, ics, rep, verb, verbL);

        make_spcs_topography_report(obj, bss, ics, data, rep, maxVar, maxAbsVar, verb, verbL);

        make_backprojection_report(obj, bss, ics, rep, verb, verbL);

    end

    methods (Access = protected)

        % override from abstract_node
        function bool = has_runtime_config(~)
            bool = true;
        end

    end

    methods

        y = predict_selection(obj, featVal);

        % Node interface
        obj = train(obj, trainInput, varargin);

        [data, dataNew] = process(obj, data, varargin);

        % Constructor
        function obj = bss(varargin)
            import exceptions.*;
            import misc.prepend_varargin;

            dataSel = pset.selector.good_data;
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);
            obj = obj@meegpipe.node.abstract_node(varargin{:});

            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            if isempty(get_name(obj)),
                obj = set_name(obj, 'bss');
            end
        end

    end
end