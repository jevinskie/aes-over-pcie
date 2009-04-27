SRCDIR = source
MAPPEDDIR = mapped
WORKDIR = work
SCRIPTDIR = scripts
TESTVECTDIR = test_vectors
UTILSDIR = utils

CFLAGS = -quiet

TOP_LEVEL = top_top

ENTITIES =	add_round_key		   \
            add_round_key_p      \
				aes_rcu				   \
				aes_top				   \
				aes					   \
				bridge				   \
            fifo                 \
				key_scheduler		   \
				mix_columns			   \
            mix_columns_p        \
				reduce_pack			   \
				pcie					   \
				pcie_top				   \
				sbox					   \
            sub_bytes_p          \
				shift_rows			   \
            shift_rows_p         \
				state_filter_in	   \
				state_filter_out	   \
            state_filter_out_p   \
				state					   \
				top_top

TEST_ENTITIES =	aes_textio           \
                  numeric_std_textio   \
                  tb_add_round_key	   \
                  tb_aes_top				\
                  tb_fifo              \
						tb_key_scheduler	   \
						tb_mix_columns		   \
						tb_sbox				   \
						tb_shift_rows			\
						tb_top_top

TEST_VECTORS =    tb_key_scheduler tb_mix_columns tb_shift_rows tb_aes_top 

ENTITY_DIRS = $(foreach ent,$(ENTITIES),$(WORKDIR)/$(ent))
TEST_ENTITY_DIRS = $(foreach test,$(TEST_ENTITIES),$(WORKDIR)/$(test))
ENTITY_SRCS = $(foreach ent,$(ENTITIES),$(SRCDIR)/$(ent).vhd)
TEST_ENTITY_SRCS = $(foreach test,$(TEST_ENTITES),$(SRCDIR)/$(test).vhd)
TEST_VECTOR_DATS = $(foreach vect,$(TEST_VECTORS),$(TESTVECTDIR)/$(vect).dat)

.PHONEY : clean_source clean_mapped all_source $(ENTITIES) $(TEST_ENTITIES) add_pads

clean_source:
	rm -rf work
	
clean_mapped:
	@echo fill me in

clean_test_vectors:
	rm -f $(TEST_VECTOR_DATS)

add_round_key: aes
add_round_key_p: aes
aes_rcu: aes
aes_top: aes add_round_key add_round_key_p aes_rcu key_scheduler  \
	mix_columns mix_columns_p sbox sub_bytes_p shift_rows          \
   shift_rows_p state_filter_in state_filter_out                  \
   state_filter_out_p state
bridge: pcie aes
fifo: aes
key_scheduler: aes
mix_columns: aes
mix_columns_p: aes mix_columns
sbox: aes reduce_pack
sub_bytes_p: aes sbox
shift_rows: aes
shift_rows_p: aes shift_rows
state_filter_in: aes
state_filter_out: aes
state_filter_out_p: aes
state: aes
pcie: aes

tb_add_round_key: aes
tb_fifo: aes
tb_mix_columns: aes
tb_sbox: aes
tb_shift_rows: aes
tb_aes_rcu: aes
tb_aes_top: aes
tb_key_scheduler: aes aes_textio
tb_top_top: aes pcie
aes_textio: aes numeric_std_textio

work:
	vlib $(WORKDIR)

$(TEST_VECTOR_DATS): $(TESTVECTDIR)/%.dat : $(TESTVECTDIR)/%.py
	PYTHONPATH=$(UTILSDIR) $< > $@

$(ENTITIES) : % : $(WORKDIR)/%
$(TEST_ENTITIES) : % : $(WORKDIR)/%

$(WORKDIR)/%: work
	vcom $(CFLAGS) -work $(WORKDIR) $(SRCDIR)/$(notdir $@).vhd

all_source: $(ENTITIES)

all_tests: $(TEST_ENTITIES)

all_test_vectors: $(TEST_VECTOR_DATS)

encounter.io: $(UTILSDIR)/add_pads.pl
	$(UTILSDIR)/add_pads.pl io > encounter.io

add_pads: $(UTILSDIR)/add_pads.pl $(MAPPEDDIR)/$(TOP_LEVEL).v
	$(UTILSDIR)/add_pads.pl v $(MAPPEDDIR)/$(TOP_LEVEL).v > tmp_v
	mv tmp_v $(MAPPEDDIR)/$(TOP_LEVEL).v

encounter.pt: $(UTILSDIR)/add_pads.pl
	$(UTILSDIR)/add_pads.pl pt > encounter.pt

