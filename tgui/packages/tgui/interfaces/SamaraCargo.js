import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Input, LabeledList, NoticeBox, Section, Table, Tabs } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 50;

export const SamaraCargo = (props, context) => {
  return (
    <Window
      title="Samara // Orbital Railgun"
      theme="grimdark"
      width={780}
      height={750}>
      <Window.Content scrollable>
        <SamaraStatus />
        <SamaraCatalog />
      </Window.Content>
    </Window>
  );
};

const SamaraStatus = (props, context) => {
  const { data } = useBackend(context);
  const { points, message } = data;
  return (
    <Section
      title="Requisition"
      buttons={(
        <Box inline bold color={points > 0 ? 'average' : 'bad'}>
          <AnimatedNumber
            value={Math.round(points)}
            format={value => formatMoney(value)} />
          {' credits'}
        </Box>
      )}>
      <LabeledList>
        <LabeledList.Item label="Signal">
          {message}
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1} italic color="label">
        {points > 0
          ? 'The railgun asks no questions. The dead need no receipts.'
          : 'The coffers are empty. Nothing will fall from the sky for you.'}
      </Box>
    </Section>
  );
};

const SamaraCatalog = (props, context) => {
  const { act, data } = useBackend(context);
  const { points } = data;
  const categories = Object.values(data.supplies || {})
    .filter(category => category.packs?.length > 0);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'samaraSearch', '');
  const [
    selectedName,
    setSelectedName,
  ] = useLocalState(context, 'samaraCategory', categories[0]?.name);
  const activeCategory = categories.find(category => {
    return category.name === selectedName;
  }) || categories[0];
  const testSearch = createSearch(searchText, pack => pack.name);
  const searching = searchText.trim().length > 0;
  const packs = searching
    ? categories
      .flatMap(category => category.packs)
      .filter(testSearch)
      .slice(0, MAX_SEARCH_RESULTS)
    : activeCategory?.packs || [];
  return (
    <Section
      title="Armoury"
      buttons={(
        <>
          Search
          <Input
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
            mx={1} />
        </>
      )}>
      {categories.length === 0 && (
        <NoticeBox>
          The armoury is sealed. No requisition data received.
        </NoticeBox>
      )}
      {categories.length > 0 && (
        <Flex>
          {!searching && (
            <Flex.Item ml={-1} mr={1}>
              <Tabs vertical>
                {categories.map(category => (
                  <Tabs.Tab
                    key={category.name}
                    selected={category.name === activeCategory.name}
                    onClick={() => setSelectedName(category.name)}>
                    {category.name} ({category.packs.length})
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Flex.Item>
          )}
          <Flex.Item grow={1} basis={0}>
            {packs.length === 0 && (
              <Box color="label">
                Nothing answers to that name.
              </Box>
            )}
            <Table>
              {packs.map(pack => (
                <Table.Row
                  key={pack.id}
                  className="candystripe">
                  <Table.Cell>
                    {pack.name}
                  </Table.Cell>
                  <Table.Cell
                    collapsing
                    textAlign="right">
                    <Button
                      fluid
                      disabled={pack.cost > points}
                      tooltip={pack.desc}
                      tooltipPosition="left"
                      onClick={() => act('add', {
                        id: pack.id,
                      })}>
                      {formatMoney(pack.cost)}
                      {' cr'}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Flex.Item>
        </Flex>
      )}
    </Section>
  );
};
