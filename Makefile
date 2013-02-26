
all:eHttpBench.erl eHttpBenchStd.erl eHttpBenchDIY.erl eHttpBenchCommon.erl 
	@erlc eHttpBenchStd.erl eHttpBenchDIY.erl eHttpBenchCommon.erl
	@chmod +x eHttpBench.erl

	@echo ""
	@echo "*** Compile is done. Please run eHttpBench.erl to do benchmark. ***" 
	@echo ""


clean:
	rm -rf *.beam *.dump


